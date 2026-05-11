import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/pending_transaction_provider.dart';
import '../providers/expense_provider.dart';
import '../models/pending_transaction.dart';
import '../models/category.dart';
import '../utils/constants.dart';

/// Full-screen list of auto-detected pending transactions.
///
/// Supports:
/// - Swipe right → Confirm (adds to expenses)
/// - Swipe left → Dismiss
/// - Tap → Edit dialog (change amount/category/title before confirming)
class PendingTransactionsScreen extends StatelessWidget {
  const PendingTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final padH = AppBreakpoints.horizontalPadding(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detected Payments',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          Consumer<PendingTransactionProvider>(
            builder: (context, provider, _) {
              if (!provider.hasPending) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _handleDismissAll(context, provider),
                child: const Text(
                  'Dismiss All',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PendingTransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.hasPending) {
            return _buildEmptyState(textColor, subtitleColor);
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(padH, AppSpacing.sm, padH, 100),
            itemCount: provider.pendingTransactions.length,
            itemBuilder: (context, index) {
              final tx = provider.pendingTransactions[index];
              return _PendingTransactionTile(
                transaction: tx,
                index: index,
                onConfirm: () => _handleConfirm(context, tx),
                onDismiss: () => _handleDismiss(context, tx),
                onTap: () => _showEditDialog(context, tx),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.accent.withValues(alpha: 0.5),
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'All caught up!',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No pending payments to review.\nDetected payments will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Future<void> _handleConfirm(
      BuildContext context, PendingTransaction tx) async {
    final provider = context.read<PendingTransactionProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final result = await provider.confirmTransaction(tx.id);

    if (result.isSuccess && context.mounted) {
      // Reload expenses to reflect the new addition
      await expenseProvider.loadExpenses();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ₹${tx.amount.toStringAsFixed(0)} '
                'to ${tx.displayTitle} added to expenses'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleDismiss(
      BuildContext context, PendingTransaction tx) async {
    final provider = context.read<PendingTransactionProvider>();
    await provider.dismissTransaction(tx.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dismissed ₹${tx.amount.toStringAsFixed(0)} '
              'to ${tx.displayTitle}'),
        ),
      );
    }
  }

  Future<void> _handleDismissAll(
      BuildContext context, PendingTransactionProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dismiss All'),
        content: const Text(
          'Are you sure you want to dismiss all detected payments? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Dismiss All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.dismissAll();
    }
  }

  void _showEditDialog(BuildContext context, PendingTransaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditTransactionSheet(transaction: tx),
    );
  }
}

// ─── Individual Transaction Tile ─────────────────────────────────

class _PendingTransactionTile extends StatelessWidget {
  final PendingTransaction transaction;
  final int index;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _PendingTransactionTile({
    required this.transaction,
    required this.index,
    required this.onConfirm,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final category = transaction.expenseCategory;
    final currencyFmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final timeFmt = DateFormat('h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: Key(transaction.id),
        // Swipe right → confirm
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onConfirm();
            return false; // We handle removal in provider
          } else {
            onDismiss();
            return false;
          }
        },
        background: _buildSwipeBackground(
          color: AppColors.success,
          icon: Icons.check_rounded,
          label: 'Confirm',
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _buildSwipeBackground(
          color: AppColors.error,
          icon: Icons.close_rounded,
          label: 'Dismiss',
          alignment: Alignment.centerRight,
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5),
              ),
            ),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 22,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.displayTitle,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            transaction.sourceApp ?? 'UPI',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' · ${timeFmt.format(transaction.detectedAt)}',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFmt.format(transaction.amount),
                      style: TextStyle(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent
                            .withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        category.label,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 + index * 60).ms, duration: 400.ms)
        .slideX(begin: 0.05, delay: (100 + index * 60).ms);
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: color, size: 24),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ] else ...[
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(icon, color: color, size: 24),
          ],
        ],
      ),
    );
  }
}

// ─── Edit Transaction Bottom Sheet ──────────────────────────────

class _EditTransactionSheet extends StatefulWidget {
  final PendingTransaction transaction;

  const _EditTransactionSheet({required this.transaction});

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late ExpenseCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.transaction.displayTitle);
    _amountController = TextEditingController(
        text: widget.transaction.amount.toStringAsFixed(2));
    _selectedCategory = widget.transaction.expenseCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, bottomInset + AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Edit Transaction',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title field
            TextField(
              controller: _titleController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Amount field
            TextField(
              controller: _amountController,
              style: TextStyle(color: textColor),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                labelStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Category selector
            Text(
              'Category',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ExpenseCategory.values.map((cat) {
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withValues(alpha: 0.2)
                          : (isDark ? AppColors.darkBg : AppColors.lightBg),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: isSelected
                            ? cat.color
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, size: 16, color: cat.color),
                        const SizedBox(width: 4),
                        Text(
                          cat.label,
                          style: TextStyle(
                            color: isSelected ? cat.color : textColor,
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _handleConfirm(context),
                      icon: const Icon(Icons.check_rounded,
                          size: 18, color: Colors.white),
                      label: const Text(
                        'Confirm & Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirm(BuildContext context) async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid title and amount')),
      );
      return;
    }

    final provider = context.read<PendingTransactionProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    final result = await provider.editAndConfirm(
      id: widget.transaction.id,
      title: title,
      amount: amount,
      category: _selectedCategory,
    );

    if (result.isSuccess && context.mounted) {
      await expenseProvider.loadExpenses();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ₹${amount.toStringAsFixed(0)} '
                'to $title added to expenses'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
