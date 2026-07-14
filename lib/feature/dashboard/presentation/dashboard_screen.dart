import 'package:budget_flow/feature/budgets/presentation/budget_list_screen.dart';
import 'package:budget_flow/feature/categories/presentation/category_list_screen.dart';
import 'package:budget_flow/feature/dashboard/presentation/dashboard_controller.dart';
import 'package:budget_flow/feature/search/presentation/search_screen.dart';
import 'package:budget_flow/feature/settings/presentation/settings_controller.dart';
import 'package:budget_flow/feature/settings/presentation/settings_screen.dart';
import 'package:budget_flow/feature/statistic/presentation/stats_screen.dart';
import 'package:budget_flow/feature/transactions/presentation/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // Fonction utilitaire pour faire correspondre le texte de la DB à l'icône Flutter réelle
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_atm':
        return Icons.local_atm;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'medical':
        return Icons.medical_services;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'alcohol':
        return Icons.local_drink;
      case 'other':
        return Icons.other_houses;
      default:
        return Icons.other_houses;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStateAsync = ref.watch(dashboardControllerProvider);

    // 1. Récupère la devise stockée (valeur par défaut si chargement en cours)
    final activeCurrency =
        ref.watch(settingsControllerProvider).value ?? 'FCFA';
    // 2. Utilisation dynamique
    final currencyFormatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: activeCurrency,
      decimalDigits: activeCurrency == 'FCFA'
          ? 0
          : 2, // Pas de virgules pour les FCFA !
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BudgetFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.category_outlined),
            onPressed: () {
              // Navigation temporaire vers la gestion des catégories
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.history_outlined),
            onPressed: () {
              // Navigation temporaire vers l'historique complet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: dashboardStateAsync.when(
        data: (state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CARTE DE CREDIT VIRTUELLE (SOLDE GLOBAL) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Color(0xFF0F5132),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Solde Actuel",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(state.totalBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "**** **** **** 2026",
                            style: TextStyle(
                              color: Colors.white60,
                              letterSpacing: 2,
                            ),
                          ),
                          Icon(Icons.contactless, color: Colors.white60),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- RECAPITULATIF DU MOIS (REVENUS / DEPENSES) ---
                Row(
                  children: [
                    // Carte Revenus
                    Expanded(
                      child: Card(
                        elevation: 1,
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Revenus",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormatter.format(state.monthlyIncomes),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Carte Dépenses
                    Expanded(
                      child: Card(
                        elevation: 1,
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.arrow_upward, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text(
                                    "Dépenses",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormatter.format(state.monthlyExpenses),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- DERNIERES TRANSACTIONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Transactions Récentes",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionListScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Voir tout",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                state.recentTransactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text("Aucune transaction récente."),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap:
                            true, // Très important pour s'intégrer dans le SingleChildScrollView
                        physics:
                            const NeverScrollableScrollPhysics(), // Désactive le scroll propre à la liste
                        itemCount: state.recentTransactions.length,
                        itemBuilder: (context, index) {
                          final item = state.recentTransactions[index];
                          final isExpense = item.transaction.type == 'expense';
                          final categoryColor = Color(item.category.colorValue);

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: categoryColor.withValues(
                                alpha: 0.15,
                              ),
                              foregroundColor: categoryColor,
                              child: Icon(_getIconData(item.category.icon)),
                            ),
                            title: Text(
                              item.transaction.comment ?? item.category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat(
                                'dd MMM yyyy',
                                'fr_FR',
                              ).format(item.transaction.date),
                            ),
                            trailing: Text(
                              "${isExpense ? '-' : '+'}${currencyFormatter.format(item.transaction.amount)}",
                              style: TextStyle(
                                color: isExpense ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erreur de chargement : $err")),
      ),
    );
  }
}
