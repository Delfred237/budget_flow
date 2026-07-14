import 'dart:async';
import 'package:budget_flow/feature/budgets/data/budget_repository_impl.dart';
import 'package:budget_flow/feature/budgets/domain/budget_with_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetController extends AsyncNotifier<List<BudgetWithCategory>> {
  @override
  FutureOr<List<BudgetWithCategory>> build() async {
    final repo = ref.watch(budgetRepositoryProvider);

    final controller = StreamController<List<BudgetWithCategory>>();
    final subscription = repo.watchBudgetsWithCategory().listen((data) {
      state = AsyncValue.data(data);
    });

    ref.onDispose(() {
      subscription.cancel();
      controller.close();
    });

    return repo.watchBudgetsWithCategory().first;
  }

  Future<void> saveBudget({required double limit, required int categoryId}) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(budgetRepositoryProvider).setBudget(limitAmount: limit, categoryId: categoryId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeBudget(int id) async {
    try {
      await ref.read(budgetRepositoryProvider).deleteBudget(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final budgetControllerProvider = AsyncNotifierProvider<BudgetController, List<BudgetWithCategory>>(() {
  return BudgetController();
});