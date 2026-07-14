import 'package:budget_flow/feature/settings/presentation/settings_controller.dart';
import 'package:budget_flow/feature/statistic/presentation/stats_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

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
    final statsState = ref.watch(statsControllerProvider);

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
        title: const Text('Mes Statistiques'),
      ),
      body: statsState.when(
        data: (stats) {
          if (stats.isEmpty) {
            return const Center(
              child: Text(
                "Aucune dépense enregistrée ce mois-ci.\nAjoutez des transactions pour voir vos graphiques !",
                textAlign: TextAlign.center,
              ),
            );
          }

          // Préparation des sections du graphique circulaire
          final List<PieChartSectionData> sections = stats.map((item) {
            final color = Color(item.category.colorValue);
            return PieChartSectionData(
              color: color,
              value: item.totalAmount,
              title: '${(item.percentage * 100).toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Répartition des dépenses de ce mois",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // --- LE GRAPHIQUE EN SECTEURS (PieChart) ---
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- LÉGENDE & DÉTAILS ---
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.length,
                  itemBuilder: (context, index) {
                    final item = stats[index];
                    final color = Color(item.category.colorValue);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.15),
                          foregroundColor: color,
                          child: Icon(
                            _getIconData(item.category.icon),
                          ),
                        ),
                        title: Text(
                          item.category.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${(item.percentage * 100).toStringAsFixed(1)}% des dépenses",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          currencyFormatter.format(item.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
        error: (err, _) => Center(child: Text("Erreur : $err")),
      ),
    );
  }
}
