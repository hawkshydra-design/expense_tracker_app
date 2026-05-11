import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  late final _router = buildAppRouter(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDark;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF5F5FA),
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp.router(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
