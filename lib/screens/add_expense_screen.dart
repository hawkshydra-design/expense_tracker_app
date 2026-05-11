import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/income_category.dart';
import '../utils/constants.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  IncomeCategory _selectedIncomeCategory = IncomeCategory.salary;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;
  TransactionType _transactionType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _isEditing = true;
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _noteController.text = widget.expense!.note ?? '';
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      _transactionType = widget.expense!.type;
      if (widget.expense!.incomeCategory != null) {
        _selectedIncomeCategory = widget.expense!.incomeCategory!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isIncome => _transactionType == TransactionType.income;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final provider = context.read<ExpenseProvider>();

    if (_isEditing) {
      provider.updateExpense(widget.expense!.copyWith(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        category: _isIncome ? ExpenseCategory.other : _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        type: _transactionType,
        incomeCategory: _isIncome ? _selectedIncomeCategory : null,
      ));
    } else if (_isIncome) {
      provider.addIncome(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        incomeCategory: _selectedIncomeCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
    } else {
      provider.addExpense(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? (_isIncome ? 'Edit Income' : 'Edit Expense')
            : (_isIncome ? 'Add Income' : 'Add Expense')),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close_rounded, color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Transaction Type Toggle ─────────────────
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: borderColor.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeToggleButton(
                        label: 'Expense',
                        icon: Icons.arrow_upward_rounded,
                        isSelected: !_isIncome,
                        color: AppColors.expense,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _transactionType = TransactionType.expense);
                        },
                      ),
                    ),
                    Expanded(
                      child: _TypeToggleButton(
                        label: 'Income',
                        icon: Icons.arrow_downward_rounded,
                        isSelected: _isIncome,
                        color: AppColors.income,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _transactionType = TransactionType.income);
                        },
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Text('Title', style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w600))
                  .animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _titleController,
                hintText: _isIncome ? 'e.g. Salary, Freelance Payment' : 'e.g. Coffee, Groceries',
                prefixIcon: Icons.edit_rounded,
                validator: (v) => v?.trim().isEmpty == true ? 'Title required' : null,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.05),

              const SizedBox(height: AppSpacing.lg),

              // Amount
              Text('Amount', style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w600))
                  .animate().fadeIn(delay: 150.ms, duration: 300.ms),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _amountController,
                hintText: '0.00',
                prefixIcon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount required';
                  final amount = double.tryParse(v.trim());
                  if (amount == null || amount <= 0) return 'Enter a valid amount';
                  return null;
                },
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: -0.05),

              const SizedBox(height: AppSpacing.lg),

              // Category
              Text(
                _isIncome ? 'Income Source' : 'Category',
                style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w600),
              ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
              const SizedBox(height: AppSpacing.sm),

              // Animated switcher between expense and income categories
              AnimatedSwitcher(
                duration: AppDurations.normal,
                child: _isIncome
                    ? _buildIncomeCategoryChips(cardColor, borderColor, subtitleColor, textColor)
                    : _buildExpenseCategoryChips(cardColor, borderColor, subtitleColor, textColor),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.lg),

              // Date
              Text('Date', style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w600))
                  .animate().fadeIn(delay: 350.ms, duration: 300.ms),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: borderColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, color: subtitleColor),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.lg),

              // Note
              Text('Note (optional)', style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w600))
                  .animate().fadeIn(delay: 450.ms, duration: 300.ms),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _noteController,
                hintText: 'Add a note...',
                prefixIcon: Icons.note_rounded,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.xl),

              // Save button
              GradientButton(
                text: _isEditing
                    ? (_isIncome ? 'Update Income' : 'Update Expense')
                    : (_isIncome ? 'Add Income' : 'Add Expense'),
                onPressed: _saveExpense,
                icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCategoryChips(Color cardColor, Color borderColor, Color subtitleColor, Color textColor) {
    return Wrap(
      key: const ValueKey('expense_cats'),
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ExpenseCategory.values.map((cat) {
        final isSelected = _selectedCategory == cat;
        final catColors = AppColors.categoryGradients[cat.index];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = cat);
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: catColors) : null,
              color: isSelected ? null : cardColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? Colors.transparent : borderColor.withValues(alpha: 0.4),
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: catColors[0].withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, size: 16, color: isSelected ? Colors.white : subtitleColor),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIncomeCategoryChips(Color cardColor, Color borderColor, Color subtitleColor, Color textColor) {
    return Wrap(
      key: const ValueKey('income_cats'),
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: IncomeCategory.values.map((cat) {
        final isSelected = _selectedIncomeCategory == cat;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedIncomeCategory = cat);
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: [cat.color, cat.color.withValues(alpha: 0.7)])
                  : null,
              color: isSelected ? null : cardColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? Colors.transparent : borderColor.withValues(alpha: 0.4),
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: cat.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, size: 16, color: isSelected ? Colors.white : subtitleColor),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Toggle button for switching between Expense and Income mode
class _TypeToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : AppColors.lightTextMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.lightTextMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
