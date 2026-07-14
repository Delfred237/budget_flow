import 'package:budget_flow/core/database/app_database.dart';

class BudgetWithCategory {
  final Budget budget;
  final Category category;
  final double amountSpent;

  BudgetWithCategory({
    required this.budget,
    required this.category,
    required this.amountSpent,
  });

  double get percentUsed => budget.limitAmount > 0
      ? (amountSpent / budget.limitAmount).clamp(0.0, 1.0)
      : 0.0;

  double get remainingAmount => budget.limitAmount - amountSpent;

  bool get isOverBudget => amountSpent > budget.limitAmount;
}
