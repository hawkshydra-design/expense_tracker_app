import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// Interactive pie chart widget for expense category breakdown.
class PieChartWidget extends StatefulWidget {
  final Map<ExpenseCategory, double> categoryData;

  const PieChartWidget({super.key, required this.categoryData});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (widget.categoryData.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: TextStyle(color: subtitleColor, fontSize: 14),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: _buildSections(),
              centerSpaceRadius: 45,
              sectionsSpace: 3,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Legend
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: widget.categoryData.entries.map((entry) {
            final catColors = AppColors.categoryGradients[entry.key.index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: catColors),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${entry.key.label}: ${context.read<CurrencyProvider>().format(entry.value)}',
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = widget.categoryData.values.fold(0.0, (s, v) => s + v);
    return widget.categoryData.entries.toList().asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final isTouched = index == _touchedIndex;
      final pct = total > 0 ? entry.value / total * 100 : 0.0;
      final catColors = AppColors.categoryGradients[entry.key.index];

      return PieChartSectionData(
        value: entry.value,
        color: catColors[0],
        radius: isTouched ? 60 : 50,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }
}
