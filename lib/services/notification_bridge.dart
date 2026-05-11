import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/pending_transaction.dart';
import '../repositories/pending_transaction_repository.dart';
import 'transaction_parser.dart';
import 'auto_categorizer.dart';

/// Central orchestration service for auto-detecting UPI payments
/// from Android notification stream.
///
/// Responsibilities:
/// 1. Filter notifications by known UPI/bank app package names
/// 2. Deduplicate within 60-second window (same amount + merchant)
/// 3. Parse notification text via [TransactionParser]
/// 4. Auto-categorize via [AutoCategorizer]
/// 5. Insert into pending transaction queue
///
/// Uses native Kotlin platform channels instead of a third-party plugin:
/// - [MethodChannel] for permission checks & opening system settings
/// - [EventChannel] for streaming notification data from the native service
class NotificationBridge {
  final PendingTransactionRepository _pendingRepo;
  final Uuid _uuid = const Uuid();

  StreamSubscription? _subscription;
  String _activeUserId = '';

  /// Platform channels matching the native Kotlin registration in MainActivity
  static const _methodChannel =
      MethodChannel('com.expense.expense_tracker/notification');
  static const _eventChannel =
      EventChannel('com.expense.expense_tracker/notifications_stream');

  /// Callback invoked when a new pending transaction is detected.
  /// UI can listen to this for showing banners / local notifications.
  void Function(PendingTransaction)? onTransactionDetected;

  /// SharedPreferences key for auto-detect toggle
  static const _enabledKey = 'auto_detect_enabled';

  /// Known UPI / banking app package names to monitor
  static const _monitoredApps = <String>{
    // ── UPI Payment Apps ──────────────────────────────────────
    'com.google.android.apps.nbu.paisa.user', // Google Pay
    'net.one97.paytm',                         // Paytm
    'com.phonepe.app',                         // PhonePe
    'in.amazon.mShop.android.shopping',        // Amazon Pay
    'com.whatsapp',                            // WhatsApp Pay
    'in.org.npci.upiapp',                      // BHIM
    'com.myairtel.upi',                        // Airtel Payments
    'com.freecharge.android',                  // Freecharge
    'com.mobikwik_new',                        // MobiKwik
    'com.jio.myjio',                           // JioPay
    'com.cred.android',                        // CRED UPI
    'com.slice',                               // Slice
    // ── SMS / Messaging Apps (bank SMS alerts) ───────────────
    'com.google.android.apps.messaging',       // Google Messages
    'com.samsung.android.messaging',           // Samsung Messages
    'com.android.mms',                         // AOSP default SMS
    'com.miui.mms',                            // Xiaomi/MIUI Messages
    'com.oneplus.mms',                         // OnePlus Messages
    'com.oppo.mms',                            // Oppo Messages
    'com.coloros.mms',                         // Oppo/ColorOS Messages
    'com.vivo.mms',                            // Vivo Messages
    'com.iqoo.mms',                            // iQOO Messages
    'com.realme.mms',                          // Realme Messages
    'com.huawei.mms',                          // Huawei Messages
    'com.motorola.mms',                        // Motorola Messages
    'com.asus.mms',                            // Asus Messages
    'com.nokia.mms',                           // Nokia Messages
    'com.lge.mms',                             // LG Messages
    'com.lenovo.mms',                          // Lenovo Messages
    'com.transsion.mms',                       // Tecno/Infinix/Itel
    'org.thoughtcrime.securesms',              // Signal (as SMS)
    'com.textra',                              // Textra SMS
    'xyz.klinker.messenger',                   // Pulse SMS
    'com.microsoft.android.smsorganizer',      // Microsoft SMS Organizer
    // ── Major Indian Bank Apps ───────────────────────────────
    'com.sbi.SBIFreedomPlus',                  // SBI YONO
    'com.sbi.lotusintouch',                    // SBI YONO Lite
    'com.csam.icici.bank.imobile',             // ICICI iMobile
    'com.axis.mobile',                         // Axis Mobile
    'com.msf.kbank.mobile',                    // Kotak Mobile
    'com.hdfc.retail.banking',                 // HDFC MobileBanking
    'com.snapwork.hdfc',                       // HDFC PayZapp
    'com.pnb.ebanking',                        // PNB ONE
    'com.unionbank',                           // Union Bank
    'com.bankofbaroda.mconnect',               // Bank of Baroda
    'com.infrasofttech.CentralBank',           // Central Bank
    'com.bob.bmir.boa',                        // BOI
    'com.canaaboroda.mbanking',                // Canara Bank
    'in.co.indiapost.payments',                // India Post Payments
    'com.idbi.mpassbook',                      // IDBI
    'com.fss.iob',                             // IOB
  };

  /// Recent detections for deduplication: key = "amount|merchant"
  final Map<String, DateTime> _recentDetections = {};

  /// Deduplication window
  static const _dedupeWindow = Duration(seconds: 60);

  /// Maximum entries in the in-memory deduplication map before pruning
  static const _maxDedupeEntries = 500;

  NotificationBridge({
    required PendingTransactionRepository pendingRepo,
  }) : _pendingRepo = pendingRepo;

  /// Check if auto-detection is enabled in settings
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Toggle auto-detection on/off
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  /// Check if notification listener permission is granted.
  /// Uses native MethodChannel to query Android system settings.
  static Future<bool> isPermissionGranted() async {
    try {
      final bool granted =
          await _methodChannel.invokeMethod('isPermissionGranted') ?? false;
      return granted;
    } catch (e) {
      debugPrint('NotificationBridge: Permission check failed: $e');
      return false;
    }
  }

  /// Open system settings to grant notification access.
  /// Returns true after launching the settings intent.
  static Future<bool> requestPermission() async {
    try {
      await _methodChannel.invokeMethod('requestPermission');
      return true;
    } catch (e) {
      debugPrint('NotificationBridge: Failed to request permission: $e');
      return false;
    }
  }

  /// Start listening to the notification stream.
  /// Call this after user authenticates and feature is enabled.
  Future<void> startListening(String userId) async {
    _activeUserId = userId;

    // Don't start if feature is disabled
    final enabled = await isEnabled();
    if (!enabled) return;

    // Don't start if permission isn't granted
    final hasPermission = await isPermissionGranted();
    if (!hasPermission) return;

    // Cancel any existing subscription
    await stopListening();

    try {
      _subscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            _handleNotification(Map<String, dynamic>.from(event));
          }
        },
        onError: (error) {
          debugPrint('NotificationBridge: Stream error: $error');
        },
      );
      debugPrint('NotificationBridge: Started listening for user $userId');
    } catch (e) {
      debugPrint('NotificationBridge: Failed to start listening: $e');
    }
  }

  /// Stop listening to notifications
  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    debugPrint('NotificationBridge: Stopped listening');
  }

  /// Handle an incoming notification event from the native EventChannel.
  /// The [event] map contains: packageName, title, text, timestamp.
  Future<void> _handleNotification(Map<String, dynamic> event) async {
    if (_activeUserId.isEmpty) return;

    final packageName = (event['packageName'] as String?) ?? '';
    final title = (event['title'] as String?) ?? '';
    final text = (event['text'] as String?) ?? '';
    // Combine title + text for more reliable parsing
    final fullText = '$title $text'.trim();

    // 1. Filter: only process known UPI/bank apps
    if (!_isMonitoredApp(packageName)) return;

    // 2. Parse: extract transaction details
    final parsed = TransactionParser.parse(
      text: fullText,
      sourceApp: packageName,
    );
    if (parsed == null) return;

    // 3. Deduplicate: skip if same amount+merchant within window
    if (_isDuplicateInMemory(parsed.amount, parsed.merchant)) return;

    // Also check database for duplicates
    final dbDuplicate = await _pendingRepo.isDuplicate(
      userId: _activeUserId,
      amount: parsed.amount,
      merchant: parsed.merchant,
      window: _dedupeWindow,
    );
    if (dbDuplicate) return;

    // 4. Categorize
    final category = AutoCategorizer.categorize(
      merchant: parsed.merchant,
      rawText: parsed.rawText,
    );

    // 5. Create pending transaction
    final pending = PendingTransaction(
      id: _uuid.v4(),
      userId: _activeUserId,
      amount: parsed.amount,
      merchant: parsed.merchant,
      category: category.name,
      rawNotification: parsed.rawText,
      sourceApp: _friendlyAppName(packageName),
      detectedAt: DateTime.now(),
    );

    // 6. Insert into database
    try {
      await _pendingRepo.insertPending(pending);
      _markDetected(parsed.amount, parsed.merchant);

      // Notify listeners (for UI update / local notification)
      onTransactionDetected?.call(pending);

      debugPrint('NotificationBridge: Detected ₹${parsed.amount} '
          'to ${parsed.merchant ?? "unknown"} via $packageName');
    } catch (e) {
      debugPrint('NotificationBridge: Failed to insert pending: $e');
    }
  }

  /// Check if a package name belongs to a monitored app
  bool _isMonitoredApp(String packageName) {
    if (_monitoredApps.contains(packageName)) return true;
    // Also match any banking / payment / SMS-related package names
    final lower = packageName.toLowerCase();
    return lower.contains('bank') ||
        lower.contains('upi') ||
        lower.contains('pay') ||
        lower.contains('mms') ||
        lower.contains('messaging') ||
        lower.contains('message') ||
        lower.contains('sms');
  }

  /// In-memory deduplication check
  bool _isDuplicateInMemory(double amount, String? merchant) {
    final key = '${amount.toStringAsFixed(2)}|${merchant ?? ""}';
    final lastSeen = _recentDetections[key];
    if (lastSeen != null) {
      final elapsed = DateTime.now().difference(lastSeen);
      if (elapsed < _dedupeWindow) return true;
    }
    return false;
  }

  /// Record a detection for deduplication
  void _markDetected(double amount, String? merchant) {
    final key = '${amount.toStringAsFixed(2)}|${merchant ?? ""}';
    _recentDetections[key] = DateTime.now();

    // Cleanup old entries periodically
    _recentDetections.removeWhere((_, time) =>
        DateTime.now().difference(time) > _dedupeWindow * 2);

    // Hard cap to prevent unbounded growth during long sessions
    if (_recentDetections.length > _maxDedupeEntries) {
      final sorted = _recentDetections.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final toRemove = sorted.take(_recentDetections.length ~/ 2);
      for (final entry in toRemove) {
        _recentDetections.remove(entry.key);
      }
    }
  }

  /// Convert package name to friendly display name
  static String _friendlyAppName(String packageName) {
    const appNames = {
      // UPI Apps
      'com.google.android.apps.nbu.paisa.user': 'Google Pay',
      'net.one97.paytm': 'Paytm',
      'com.phonepe.app': 'PhonePe',
      'in.amazon.mShop.android.shopping': 'Amazon Pay',
      'com.whatsapp': 'WhatsApp Pay',
      'in.org.npci.upiapp': 'BHIM',
      'com.myairtel.upi': 'Airtel Pay',
      'com.freecharge.android': 'Freecharge',
      'com.mobikwik_new': 'MobiKwik',
      'com.jio.myjio': 'JioPay',
      'com.cred.android': 'CRED',
      'com.slice': 'Slice',
      // SMS / Messaging Apps
      'com.google.android.apps.messaging': 'SMS',
      'com.samsung.android.messaging': 'SMS',
      'com.android.mms': 'SMS',
      'com.miui.mms': 'SMS',
      'com.oneplus.mms': 'SMS',
      'com.oppo.mms': 'SMS',
      'com.coloros.mms': 'SMS',
      'com.vivo.mms': 'SMS',
      'com.iqoo.mms': 'SMS',
      'com.realme.mms': 'SMS',
      'com.huawei.mms': 'SMS',
      'com.motorola.mms': 'SMS',
      'com.asus.mms': 'SMS',
      'com.nokia.mms': 'SMS',
      'com.lge.mms': 'SMS',
      'com.lenovo.mms': 'SMS',
      'com.transsion.mms': 'SMS',
      'org.thoughtcrime.securesms': 'Signal SMS',
      'com.textra': 'Textra SMS',
      'xyz.klinker.messenger': 'Pulse SMS',
      'com.microsoft.android.smsorganizer': 'MS SMS Organizer',
      // Bank Apps
      'com.sbi.SBIFreedomPlus': 'SBI YONO',
      'com.sbi.lotusintouch': 'SBI YONO Lite',
      'com.csam.icici.bank.imobile': 'ICICI iMobile',
      'com.axis.mobile': 'Axis Mobile',
      'com.msf.kbank.mobile': 'Kotak',
      'com.hdfc.retail.banking': 'HDFC Mobile',
      'com.snapwork.hdfc': 'HDFC PayZapp',
      'com.pnb.ebanking': 'PNB ONE',
    };
    return appNames[packageName] ?? packageName.split('.').last;
  }

  /// Dispose the bridge
  Future<void> dispose() async {
    await stopListening();
    _recentDetections.clear();
    onTransactionDetected = null;
  }
}
