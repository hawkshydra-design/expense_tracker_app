import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported currencies with their symbols and locale info.
class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });
}

/// Provides currency selection with persistence.
/// Used across the app for formatting amounts.
class CurrencyProvider extends ChangeNotifier {
  static const _key = 'selected_currency';

  static const List<CurrencyInfo> supportedCurrencies = [
    CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
    CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    CurrencyInfo(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
    CurrencyInfo(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
    CurrencyInfo(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    CurrencyInfo(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham', flag: '🇦🇪'),
    CurrencyInfo(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal', flag: '🇸🇦'),
    CurrencyInfo(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka', flag: '🇧🇩'),
    CurrencyInfo(code: 'PKR', symbol: 'Rs', name: 'Pakistani Rupee', flag: '🇵🇰'),
    CurrencyInfo(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', flag: '🇸🇬'),
    CurrencyInfo(code: 'THB', symbol: '฿', name: 'Thai Baht', flag: '🇹🇭'),
    CurrencyInfo(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', flag: '🇧🇷'),
    CurrencyInfo(code: 'RUB', symbol: '₽', name: 'Russian Ruble', flag: '🇷🇺'),
  ];

  CurrencyInfo _selected;

  CurrencyInfo get selected => _selected;
  String get symbol => _selected.symbol;
  String get code => _selected.code;

  CurrencyProvider({CurrencyInfo? initial})
      : _selected = initial ?? supportedCurrencies.first;

  /// Pre-load saved currency before creating provider (prevents flash).
  static Future<CurrencyInfo> loadSavedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'INR';
    return supportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => supportedCurrencies.first,
    );
  }

  /// Change currency and persist.
  Future<void> setCurrency(CurrencyInfo currency) async {
    _selected = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currency.code);
  }

  /// Format an amount with the current currency symbol.
  String format(double amount) {
    if (amount >= 100000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }
}
