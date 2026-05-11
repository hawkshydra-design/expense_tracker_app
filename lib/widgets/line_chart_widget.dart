import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// Monthly spending trend line chart.
/// Shows spending over the last 6 months with gradient fill.
class LineChartWidget extends StatelessWidget {
  final Map<String, double> monthlyData;
  final String? highlightMonth;

  const LineChartWidget({
    super.key,
    required this.monthlyData,
    this.highlightMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (monthlyData.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data yet',
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
      );
    }

    final months = monthlyData.keys.toList();
    final values = monthlyData.values.toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final adjustedMax = maxVal == 0 ? 100.0 : maxVal * 1.2;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: adjustedMax / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: adjustedMax / 4,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      _formatCompactAmount(value),
                      style: TextStyle(
                        color: textColor,
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
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                  final isHighlighted = months[idx] == highlightMonth;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[idx],
                      style: TextStyle(
                        color: isHighlighted
                            ? AppColors.primary
                            : textColor,
                        fontSize: 11,
                        fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (months.length - 1).toDouble(),
          minY: 0,
          maxY: adjustedMax,
          lineBarsData: [
            LineChartBarData(
              spots: values.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: isDark ? AppColors.darkCard : Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => isDark ? AppColors.darkCard : AppColors.lightCard,
              tooltipBorder: BorderSide(
                color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withValues(alpha: 0.5),
              ),
              tooltipRoundedRadius: AppRadius.sm,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    context.read<CurrencyProvider>().format(spot.y),
                    TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      ),
    );
  }

  String _formatCompactAmount(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}
