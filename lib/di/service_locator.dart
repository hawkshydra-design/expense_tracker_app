import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'dart:io' show Platform;
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/notification_bridge.dart';
import '../services/event_bus.dart';
import '../services/dao/expense_dao.dart';
import '../services/dao/pending_transaction_dao.dart';
import '../repositories/expense_repository.dart';
import '../repositories/pending_transaction_repository.dart';

final getIt = GetIt.instance;

/// Initialize all service dependencies.
///
/// Simplified after Firebase migration:
/// - Removed: EmailService, OtpService, SessionService, UserDao, OtpDao
/// - Auth is now handled by Firebase (no local user/OTP storage)
Future<void> setupServiceLocator() async {
  // Database — the single connection owner (still needed for expenses)
  final dbService = DatabaseService();
  getIt.registerLazySingleton<DatabaseService>(() => dbService);

  // Event bus — lightweight pub/sub for cross-provider communication
  getIt.registerLazySingleton<EventBus>(() => EventBus());

  // Register repository interfaces backed by focused DAO classes
  // (only expense + pending — user/OTP repos removed with Firebase migration)
  getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseDao(dbService));
  getIt.registerLazySingleton<PendingTransactionRepository>(
    () => PendingTransactionDao(dbService),
  );

  // Auth service — now backed by Firebase Auth + Google Sign-In
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Notification Bridge (Android-only) with proper dispose
  if (!kIsWeb && Platform.isAndroid) {
    getIt.registerLazySingleton<NotificationBridge>(
      () => NotificationBridge(
        pendingRepo: getIt<PendingTransactionRepository>(),
      ),
      dispose: (bridge) => bridge.dispose(),
    );
  }

  // Warm up the database
  await dbService.database;
}
