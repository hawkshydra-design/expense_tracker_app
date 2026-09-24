import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// A bar chart widget that displays spending or income data
/// for daily (7 bars), weekly (4 bars), or monthly (6 bars) periods.
class SpendingBarChart extends StatelessWidget {
  final Map<String, double> data;
  final Color barColor;
  final String currencySymbol;

  const SpendingBarChart({
    super.key,
    required this.data,
    required this.barColor,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final entries = data.entries.toList();
    final maxValue =
        data.values.isEmpty ? 1.0 : data.values.reduce((a, b) => a > b ? a : b);
    final adjustedMax = maxValue == 0 ? 1.0 : maxValue * 1.2;

    if (entries.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data yet',
            style: TextStyle(color: subtitleColor, fontSize: 14),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: adjustedMax,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = entries[group.x.toInt()].key;
                final value = rod.toY;
                return BarTooltipItem(
                  '$label\n$currencySymbol${_formatAmount(value)}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      _formatShortAmount(value),
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      entries[index].key,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: adjustedMax / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: subtitleColor.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: entries.length <= 4 ? 24 : 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      barColor.withValues(alpha: 0.7),
                      barColor,
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  String _formatShortAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(0)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}
