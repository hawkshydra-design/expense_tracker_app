import 'package:flutter/material.dart';

/// Expense categories with display metadata.
/// Uses Dart 3 enhanced enums — replaces the previous extension-based approach.
enum ExpenseCategory {
  food(
    label: 'Food',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFFF6B6B),
  ),
  transport(
    label: 'Transport',
    icon: Icons.directions_car_rounded,
    color: Color(0xFF4ECDC4),
  ),
  shopping(
    label: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFFFFE66D),
  ),
  bills(
    label: 'Bills',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFFA8E6CF),
  ),
  entertainment(
    label: 'Entertainment',
    icon: Icons.movie_rounded,
    color: Color(0xFFDDA0DD),
  ),
  health(
    label: 'Health',
    icon: Icons.favorite_rounded,
    color: Color(0xFFFF8A80),
  ),
  education(
    label: 'Education',
    icon: Icons.school_rounded,
    color: Color(0xFF82B1FF),
  ),
  other(
    label: 'Other',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFFB0BEC5),
  );

  final String label;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  /// Parse a category name string back to enum value.
  /// Falls back to [other] if not found.
  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
