import 'dart:async';

import 'package:budget_flow/core/database/app_database.dart';
import 'package:budget_flow/core/notifications/notification_service.dart';
import 'package:budget_flow/feature/budgets/data/budget_repository_impl.dart';
import 'package:budget_flow/feature/budgets/presentation/budget_controller.dart';
import 'package:budget_flow/feature/transactions/data/transaction_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionController
    extends AsyncNotifier<List<TransactionWithCategory>> {
  @override
  Future<List<TransactionWithCategory>> build() async {
    final repo = ref.watch(transactionRepositoryProvider);

    final controller = StreamController<List<TransactionWithCategory>>();
    final subscription = repo.watchTransactionsWithCategory().listen((
      transactions,
    ) {
      state = AsyncValue.data(transactions);
    });

    ref.onDispose(() {
      subscription.cancel();
      controller.close();
    });

    return repo.watchTransactionsWithCategory().first;
  }

  Future<void> addTransaction({
    required double amount,
    required String? comment,
    required DateTime date,
    required String type,
    required int categoryId,
  }) async {
    state = const AsyncValue.loading();

    try {
      await ref
          .read(transactionRepositoryProvider)
          .createTransaction(
            amount: amount,
            comment: comment,
            date: date,
            type: type,
            categoryId: categoryId,
          );

      if (type == 'expense') {
        _checkBudgetAlerts(categoryId, amount);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
    return;
  }

  Future<void> _checkBudgetAlerts(
    int categoryId,
    double currentExpenseAmount,
  ) async {
    try {
      final budgetRepo = ref.read(budgetRepositoryProvider);

      // On récupère la liste complète des budgets calculés
      final budgets = await budgetRepo.watchBudgetsWithCategory().first;

      // On cherche si un budget existe pour la catégorie concernée
      final match = budgets.firstWhere(
        (b) => b.category.id == categoryId,
        orElse: () => throw Exception('Aucun budget'),
      );

      final limit = match.budget.limitAmount;
      final totalSpent = match.amountSpent;
      final spentBeforeThis = totalSpent - currentExpenseAmount;

      final ratioBefore = spentBeforeThis / limit;
      final ratioAfter = totalSpent / limit;

      final notificationService = ref.read(notificationServiceProvider);

      // Cas 1 : Le budget vient d'être complètement dépassé (Seuil 100% franchi à l'instant)
      if (ratioBefore < 1.0 && ratioAfter >= 1.0) {
        await notificationService.showNotification(
          id: categoryId,
          title: "🚨 Budget Dépassé !",
          body:
              "Vous venez de dépasser votre budget pour la catégorie '${match.category.name}'.",
        );
      }
      // Cas 2 : Le seuil d'alerte des 80% vient d'être franchi à l'instant
      else if (ratioBefore < 0.8 && ratioAfter >= 0.8 && ratioAfter < 1.0) {
        await notificationService.showNotification(
          id: categoryId,
          title: "⚠️ Seuil d'Alerte Atteint (80%)",
          body:
              "Attention, vous avez consommé plus de 80% de votre budget '${match.category.name}'.",
        );
      }
    } catch (e, st) {}
  }

  Future<void> removeTransaction(int id) async {
    try {
      await ref.read(transactionRepositoryProvider).deleteTransaction(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, List<TransactionWithCategory>>(
      () => TransactionController(),
    );
