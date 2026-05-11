import 'package:flutter/material.dart';

/// Income categories with display metadata.
/// Mirrors the ExpenseCategory pattern for consistency.
enum IncomeCategory {
  salary(
    label: 'Salary',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF4CAF50),
  ),
  freelance(
    label: 'Freelance',
    icon: Icons.laptop_mac_rounded,
    color: Color(0xFF42A5F5),
  ),
  investment(
    label: 'Investment',
    icon: Icons.trending_up_rounded,
    color: Color(0xFFAB47BC),
  ),
  business(
    label: 'Business',
    icon: Icons.store_rounded,
    color: Color(0xFFFF7043),
  ),
  gift(
    label: 'Gift',
    icon: Icons.card_giftcard_rounded,
    color: Color(0xFFEC407A),
  ),
  refund(
    label: 'Refund',
    icon: Icons.replay_rounded,
    color: Color(0xFF26A69A),
  ),
  rental(
    label: 'Rental',
    icon: Icons.home_rounded,
    color: Color(0xFF8D6E63),
  ),
  other(
    label: 'Other',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF78909C),
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
