import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// Donut chart for category spending breakdown.
/// Shows categories as colored segments with center total.
class DonutChartWidget extends StatefulWidget {
  final Map<ExpenseCategory, double> data;
  final String centerLabel;

  const DonutChartWidget({
    super.key,
    required this.data,
    this.centerLabel = '',
  });

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final total = widget.data.values.fold(0.0, (s, v) => s + v);

    if (widget.data.isEmpty || total == 0) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 56,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No data to display',
                style: TextStyle(color: subtitleColor, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    _touchedIndex =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: _buildSections(total),
              centerSpaceRadius: 65,
              sectionsSpace: 3,
              startDegreeOffset: -90,
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_touchedIndex >= 0 && _touchedIndex < widget.data.length)
                _buildTouchedCenter(total)
              else ...[
                Icon(
                  Icons.pie_chart_rounded,
                  color: subtitleColor.withValues(alpha: 0.5),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  context.read<CurrencyProvider>().format(total),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.centerLabel,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTouchedCenter(double total) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final entry = widget.data.entries.toList()[_touchedIndex];
    final pct = (entry.value / total * 100).toStringAsFixed(1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(entry.key.icon, color: AppColors.categoryChartColors[entry.key.index], size: 22),
        const SizedBox(height: 4),
        Text(
          context.read<CurrencyProvider>().format(entry.value),
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '${entry.key.label} · $pct%',
          style: TextStyle(
            color: AppColors.categoryChartColors[entry.key.index],
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    return widget.data.entries.toList().asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final isTouched = index == _touchedIndex;
      final catColor = AppColors.categoryChartColors[entry.key.index];

      return PieChartSectionData(
        value: entry.value,
        color: catColor,
        radius: isTouched ? 32 : 24,
        title: '',
        borderSide: isTouched
            ? BorderSide(
                color: catColor.withValues(alpha: 0.5),
                width: 3,
              )
            : BorderSide.none,
      );
    }).toList();
  }
}
