
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/pending_transactions_screen.dart';
import '../models/expense.dart';

/// Centralized route names for type-safe navigation.
abstract class AppRoutes {
  static const splash = 'splash';
  static const login = 'login';
  static const signup = 'signup';
  static const otp = 'otp';
  static const forgotPassword = 'forgot-password';
  static const resetPassword = 'reset-password';
  static const home = 'home';
  static const addExpense = 'add-expense';
  static const pendingTransactions = 'pending-transactions';
}

/// Auth-protected routes that require authentication
const _protectedRoutes = ['/home', '/add-expense', '/pending-transactions'];

/// Auth routes that logged-in users shouldn't see
const _authRoutes = ['/login', '/signup', '/forgot-password'];

/// Builds the application's GoRouter instance with auth redirect guards.
GoRouter buildAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    // Refresh router when auth state changes
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final currentPath = state.matchedLocation;

      // Don't redirect splash — it handles its own navigation
      if (currentPath == '/splash') return null;

      // Don't redirect OTP or reset-password — they're mid-flow
      if (currentPath == '/otp' || currentPath == '/reset-password') {
        return null;
      }

      // Redirect unauthenticated users away from protected routes
      if (!isAuthenticated && _protectedRoutes.contains(currentPath)) {
        return '/login';
      }

      // Redirect authenticated users away from auth routes
      if (isAuthenticated && _authRoutes.contains(currentPath)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: AppRoutes.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-expense',
        name: AppRoutes.addExpense,
        builder: (context, state) {
          final expense = state.extra as Expense?;
          return AddExpenseScreen(expense: expense);
        },
      ),
      GoRoute(
        path: '/pending-transactions',
        name: AppRoutes.pendingTransactions,
        builder: (context, state) => const PendingTransactionsScreen(),
      ),
    ],
  );
}
