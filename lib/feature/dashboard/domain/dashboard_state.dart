import 'package:budget_flow/core/database/app_database.dart';

class DashboardState {
  final double totalBalance;
  final double monthlyIncomes;
  final double monthlyExpenses;
  final List<TransactionWithCategory> recentTransactions;

  DashboardState({
    required this.totalBalance,
    required this.monthlyIncomes,
    required this.monthlyExpenses,
    required this.recentTransactions,
  });

  // Un état initial "vide" pour éviter les valeurs nulles au démarrage
  factory DashboardState.initial() {
    return DashboardState(
      totalBalance: 0.0,
      monthlyIncomes: 0.0,
      monthlyExpenses: 0.0,
      recentTransactions: [],
    );
  }
}
