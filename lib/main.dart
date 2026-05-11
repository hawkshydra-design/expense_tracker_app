import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'app.dart';
import 'di/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/pending_transaction_provider.dart';
import 'providers/currency_provider.dart';
import 'services/auth_service.dart';
import 'services/otp_service.dart';
import 'services/session_service.dart';
import 'services/event_bus.dart';
import 'repositories/expense_repository.dart';
import 'repositories/pending_transaction_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable gesture resampling for smoother touch tracking on
  // high refresh rate displays (90Hz / 120Hz+)
  GestureBinding.instance.resamplingEnabled = true;

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize FFI for desktop platforms (Windows, macOS, Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize dependency injection
  await setupServiceLocator();

  // Pre-load saved theme and currency to prevent flash
  final savedThemeMode = await ThemeProvider.loadSavedThemeMode();
  final savedCurrency = await CurrencyProvider.loadSavedCurrency();

  // Create providers — decoupled via EventBus (no direct cross-references)
  final eventBus = getIt<EventBus>();

  final expenseProvider = ExpenseProvider(
    expenseRepo: getIt<ExpenseRepository>(),
    eventBus: eventBus,
  );

  final pendingProvider = PendingTransactionProvider(
    pendingRepo: getIt<PendingTransactionRepository>(),
    expenseRepo: getIt<ExpenseRepository>(),
    eventBus: eventBus,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialMode: savedThemeMode),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider(initial: savedCurrency),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: getIt<AuthService>(),
            otpService: getIt<OtpService>(),
            sessionService: getIt<SessionService>(),
          ),
        ),
        ChangeNotifierProvider.value(value: expenseProvider),
        ChangeNotifierProvider.value(value: pendingProvider),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
