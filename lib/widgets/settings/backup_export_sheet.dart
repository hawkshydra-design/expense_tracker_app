import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../providers/expense_provider.dart';
import '../../providers/currency_provider.dart';
import '../../utils/constants.dart';

/// Bottom sheet for exporting expense data as CSV or copying to clipboard.
class BackupExportSheet extends StatelessWidget {
  const BackupExportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
          MediaQuery.of(context).padding.bottom + AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Backup & Export',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Export CSV
          _BackupOption(
            icon: Icons.table_chart_rounded,
            iconColor: AppColors.income,
            title: 'Export as CSV',
            subtitle: 'Spreadsheet-compatible format',
            onTap: () => _exportCsv(context),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Copy to clipboard
          _BackupOption(
            icon: Icons.copy_rounded,
            iconColor: AppColors.accent,
            title: 'Copy to Clipboard',
            subtitle: 'Copy expense data as text',
            onTap: () => _copyToClipboard(context),
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final expenseProvider = context.read<ExpenseProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final expenses = expenseProvider.expenses;

    if (expenses.isEmpty) {
      Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No expenses to export')),
        );
      }
      return;
    }

    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Date,Title,Amount (${currencyProvider.code}),Category,Note');
    final dateFmt = DateFormat('yyyy-MM-dd');
    for (final e in expenses) {
      final note = (e.note ?? '').replaceAll(',', ';');
      csvBuffer.writeln(
          '${dateFmt.format(e.date)},${e.title},${e.amount},${e.category.name},$note');
    }

    try {
      final dbPath = await getDatabasesPath();
      final exportDir = Directory(p.join(dbPath, '..', 'exports'));
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final filePath = p.join(
          exportDir.path, 'expenses_${dateFmt.format(DateTime.now())}.csv');
      final file = File(filePath);
      await file.writeAsString(csvBuffer.toString());

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Exported ${expenses.length} expenses to CSV'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final expenseProvider = context.read<ExpenseProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final expenses = expenseProvider.expenses;

    if (expenses.isEmpty) {
      Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No expenses to copy')),
        );
      }
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Expense Tracker - Export');
    buffer.writeln('Generated: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}');
    buffer.writeln('Total: ${currencyProvider.format(expenseProvider.totalExpenses)}');
    buffer.writeln('---');
    final dateFmt = DateFormat('MMM dd');
    for (final e in expenses) {
      buffer.writeln(
          '${dateFmt.format(e.date)} | ${e.title} | ${currencyProvider.format(e.amount)} | ${e.category.name}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${expenses.length} expenses copied to clipboard'),
        ),
      );
    }
  }
}

// ─── Backup Option Tile ─────────────────────────────────────────

class _BackupOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;

  const _BackupOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text(subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 20),
          ],
        ),
      ),
    );
  }
}
