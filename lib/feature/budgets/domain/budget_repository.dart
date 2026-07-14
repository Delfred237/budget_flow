import 'package:budget_flow/feature/budgets/domain/budget_with_category.dart';

abstract class BudgetRepository {
  Stream<List<BudgetWithCategory>> watchBudgetsWithCategory();

  Future<void> setBudget({
    required double limitAmount,
    required int categoryId,
  });

  Future<void> deleteBudget(int id);
}
