import 'dart:async';
import 'package:budget_flow/feature/dashboard/domain/dashboard_state.dart';
import 'package:budget_flow/feature/transactions/presentation/transaction_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardController extends AsyncNotifier<DashboardState> {
  @override
  FutureOr<DashboardState> build() async {
    // 1. On surveille l'état de notre contrôleur de transactions
    final transactionsState = ref.watch(transactionControllerProvider);

    return transactionsState.when(
      data: (transactions) {
        final now = DateTime.now();
        double totalBalance = 0.0;
        double monthlyIncomes = 0.0;
        double monthlyExpenses = 0.0;

        for (final item in transactions) {
          final amount = item.transaction.amount;
          final isExpense = item.transaction.type == 'expense';

          // Calcul du solde global (toutes périodes confondues)
          if (isExpense) {
            totalBalance -= amount;
          } else {
            totalBalance += amount;
          }

          // Filtrage pour le mois en cours uniquement
          if (item.transaction.date.month == now.month && 
              item.transaction.date.year == now.year) {
            if (isExpense) {
              monthlyExpenses += amount;
            } else {
              monthlyIncomes += amount;
            }
          }
        }

        // On ne garde que les 5 transactions les plus récentes pour l'affichage rapide
        final recent = transactions.take(5).toList();

        return DashboardState(
          totalBalance: totalBalance,
          monthlyIncomes: monthlyIncomes,
          monthlyExpenses: monthlyExpenses,
          recentTransactions: recent,
        );
      },
      loading: () => DashboardState.initial(),
      error: (_, __) => DashboardState.initial(),
    );
  }
}

// Notre provider pour alimenter le tableau de bord
final dashboardControllerProvider = AsyncNotifierProvider<DashboardController, DashboardState>(() {
  return DashboardController();
});