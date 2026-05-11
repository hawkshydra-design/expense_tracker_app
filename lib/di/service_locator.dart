import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'dart:io' show Platform;
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/email_service.dart';
import '../services/otp_service.dart';
import '../services/session_service.dart';
import '../services/notification_bridge.dart';
import '../services/event_bus.dart';
import '../services/dao/expense_dao.dart';
import '../services/dao/user_dao.dart';
import '../services/dao/otp_dao.dart';
import '../services/dao/pending_transaction_dao.dart';
import '../repositories/expense_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/otp_repository.dart';
import '../repositories/pending_transaction_repository.dart';

final getIt = GetIt.instance;

/// Initialize all service dependencies.
/// Registers focused DAOs as repository implementations backed by a shared DatabaseService.
Future<void> setupServiceLocator() async {
  // Database — the single connection owner
  final dbService = DatabaseService();
  getIt.registerLazySingleton<DatabaseService>(() => dbService);

  // Event bus — lightweight pub/sub for cross-provider communication
  getIt.registerLazySingleton<EventBus>(() => EventBus());

  // Register repository interfaces backed by focused DAO classes
  getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseDao(dbService));
  getIt.registerLazySingleton<UserRepository>(() => UserDao(dbService));
  getIt.registerLazySingleton<OtpRepository>(() => OtpDao(dbService));
  getIt.registerLazySingleton<PendingTransactionRepository>(
    () => PendingTransactionDao(dbService),
  );

  // Email service
  getIt.registerLazySingleton<EmailService>(() => EmailService());

  // Session service
  getIt.registerLazySingleton<SessionService>(() => SessionService());

  // Auth service (depends on UserRepository)
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<UserRepository>()),
  );

  // OTP service (depends on OtpRepository + Email)
  getIt.registerLazySingleton<OtpService>(
    () => OtpService(getIt<OtpRepository>(), getIt<EmailService>()),
  );

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
