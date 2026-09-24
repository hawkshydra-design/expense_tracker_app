import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Expense categories with display metadata.
/// Uses Dart 3 enhanced enums — replaces the previous extension-based approach.
enum ExpenseCategory {
  food(
    label: 'Food',
    icon: LucideIcons.utensils,
    color: Color(0xFFFB7185),
  ),
  transport(
    label: 'Transport',
    icon: LucideIcons.car,
    color: Color(0xFF22D3EE),
  ),
  shopping(
    label: 'Shopping',
    icon: LucideIcons.shoppingBag,
    color: Color(0xFFF59E0B),
  ),
  bills(
    label: 'Bills',
    icon: LucideIcons.fileText,
    color: Color(0xFF34D399),
  ),
  entertainment(
    label: 'Entertainment',
    icon: LucideIcons.film,
    color: Color(0xFFA78BFA),
  ),
  health(
    label: 'Health',
    icon: LucideIcons.heart,
    color: Color(0xFFEC4899),
  ),
  education(
    label: 'Education',
    icon: LucideIcons.bookOpen,
    color: Color(0xFF60A5FA),
  ),
  other(
    label: 'Other',
    icon: LucideIcons.moreHorizontal,
    color: Color(0xFF94A3B8),
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
