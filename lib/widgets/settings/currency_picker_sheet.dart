import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';
import '../../utils/constants.dart';

/// Bottom sheet for selecting the user's preferred currency.
///
/// Displays a scrollable list of all supported currencies with
/// flag emoji, name, code, and symbol. Tapping a currency
/// updates [CurrencyProvider] and closes the sheet.
class CurrencyPickerSheet extends StatelessWidget {
  const CurrencyPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;
    final textColor =
        isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final currencyProvider = context.watch<CurrencyProvider>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.kCardBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Select Currency',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
              itemCount: CurrencyProvider.supportedCurrencies.length,
              itemBuilder: (context, index) {
                final currency = CurrencyProvider.supportedCurrencies[index];
                final isSelected =
                    currency.code == currencyProvider.selected.code;

                return GestureDetector(
                  onTap: () {
                    currencyProvider.setCurrency(currency);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.kViolet
                              .withValues(alpha: isDark ? 0.15 : 0.08)
                          : null,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.kViolet.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(currency.flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${currency.code} (${currency.symbol})',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(LucideIcons.checkCircle,
                              color: AppColors.kViolet, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
