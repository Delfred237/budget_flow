import 'package:budget_flow/feature/budgets/presentation/add_budget_dialog.dart';
import 'package:budget_flow/feature/budgets/presentation/budget_controller.dart';
import 'package:budget_flow/feature/settings/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

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
    final budgetsState = ref.watch(budgetControllerProvider);

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
        title: const Text('Mes Budgets'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddBudgetDialog(),
          );
        },
        icon: const Icon(Icons.add_chart),
        label: const Text('Nouveau Budget'),
      ),
      body: budgetsState.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "Aucun budget défini. Créez-en un pour contrôler vos dépenses !",
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final categoryColor = Color(item.category.colorValue);

              // Choix dynamique de la couleur de la jauge
              Color progressColor = Colors.green;
              if (item.percentUsed >= 0.8 && item.percentUsed < 1.0) {
                progressColor = Colors.orange;
              } else if (item.percentUsed >= 1.0) {
                progressColor = Colors.red;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: categoryColor.withValues(
                                  alpha: 0.15,
                                ),
                                foregroundColor: categoryColor,
                                child: Icon(_getIconData(item.category.icon)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              ref
                                  .read(budgetControllerProvider.notifier)
                                  .removeBudget(item.budget.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Jauge de progression linéaire
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: item.percentUsed,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Consommé : ${currencyFormatter.format(item.amountSpent)}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            "Limite : ${currencyFormatter.format(item.budget.limitAmount)}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isOverBudget
                            ? "Dépassement de ${currencyFormatter.format(item.remainingAmount.abs())} ! ⚠️"
                            : "Il vous reste : ${currencyFormatter.format(item.remainingAmount)}",
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isOverBudget ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erreur : $err")),
      ),
    );
  }
}
