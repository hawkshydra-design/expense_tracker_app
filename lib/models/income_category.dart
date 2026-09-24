import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Income categories with display metadata.
/// Mirrors the ExpenseCategory pattern for consistency.
enum IncomeCategory {
  salary(
    label: 'Salary',
    icon: LucideIcons.wallet,
    color: Color(0xFF34D399),
  ),
  freelance(
    label: 'Freelance',
    icon: LucideIcons.laptop,
    color: Color(0xFF60A5FA),
  ),
  investment(
    label: 'Investment',
    icon: LucideIcons.trendingUp,
    color: Color(0xFFA78BFA),
  ),
  business(
    label: 'Business',
    icon: LucideIcons.store,
    color: Color(0xFFF59E0B),
  ),
  gift(
    label: 'Gift',
    icon: LucideIcons.gift,
    color: Color(0xFFEC4899),
  ),
  refund(
    label: 'Refund',
    icon: LucideIcons.refreshCw,
    color: Color(0xFF22D3EE),
  ),
  rental(
    label: 'Rental',
    icon: LucideIcons.home,
    color: Color(0xFFFB7185),
  ),
  other(
    label: 'Other',
    icon: LucideIcons.moreHorizontal,
    color: Color(0xFF94A3B8),
  );

  final String label;
  final IconData icon;
  final Color color;

  const IncomeCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  /// Parse a category name string back to enum value.
  /// Falls back to [other] if not found.
  static IncomeCategory fromString(String value) {
    return IncomeCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => IncomeCategory.other,
    );
  }
}
