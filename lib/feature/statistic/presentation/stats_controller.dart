import 'dart:async';

import 'package:budget_flow/feature/statistic/domain/category_percent.dart';
import 'package:budget_flow/feature/transactions/presentation/transaction_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsController extends AsyncNotifier<List<CategoryPercentage>> {
  @override
  FutureOr<List<CategoryPercentage>> build() async {
    final transactionsState = ref.watch(transactionControllerProvider);

    return transactionsState.when(
      data: (transactions) {
        final now = DateTime.now();

        // 1. Filtrer uniquement les dépenses du mois en cours
        final monthlyExpenses = transactions.where(
          (item) =>
              item.transaction.type == 'expense' &&
              item.transaction.date.month == now.month &&
              item.transaction.date.year == now.year,
        );

        if (monthlyExpenses.isEmpty) return [];

        // 2. Grouper les montants par catégorie
        final Map<int, double> categorySums = {};
        for (final item in monthlyExpenses) {
          categorySums[item.category.id] =
              (categorySums[item.category.id] ?? 0) + item.transaction.amount;
        }

        // Calculer le total absolu des dépenses du mois
        final totalExpenses = categorySums.values.fold<double>(
          0,
          (sum, val) => sum + val,
        );

        // 3. Associer chaque catégorie à son pourcentage et la reconstruire
        final List<CategoryPercentage> statsList = [];
        for (final entry in categorySums.entries) {
          final firstMatch = transactions.firstWhere(
            (t) => t.category.id == entry.key,
          );
          final category = firstMatch.category;

          statsList.add(
            CategoryPercentage(
              category: category,
              totalAmount: entry.value,
              percentage: totalExpenses > 0 ? entry.value / totalExpenses : 0.0,
            ),
          );
        }

        // Trier par montant décroissant pour un affichage propre
        statsList.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

        return statsList;
      },

      loading: () => [],
      error: (_, _) => [],
    );
  }
}

// Provider alimentant l' écran de statistiques
final statsControllerProvider =
    AsyncNotifierProvider<StatsController, List<CategoryPercentage>>(() {
      return StatsController();
    });
