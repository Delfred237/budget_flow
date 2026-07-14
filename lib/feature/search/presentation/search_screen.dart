import 'package:budget_flow/feature/categories/presentation/category_controller.dart';
import 'package:budget_flow/feature/search/domain/search_filters.dart';
import 'package:budget_flow/feature/search/presentation/search_controller.dart';
import 'package:budget_flow/feature/settings/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

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
    final filters = ref.watch(searchFiltersProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final categoriesState = ref.watch(categoryControllerProvider);

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
        title: const Text('Rechercher & Filtrer'),
      ),
      body: Column(
        children: [
          // --- BARRE DE RECHERCHE TEXTUELLE & BOUTONS DE CONFIG ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un commentaire, une catégorie...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                ref
                    .read(searchFiltersProvider.notifier)
                    .updateFilters(filters.copyWith(query: value));
              },
            ),
          ),

          // --- FILTRES RAPIDES (HORIZONTAL SCROLL) ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Filtre Type
                DropdownButton<String>(
                  value: filters.type,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous types')),
                    DropdownMenuItem(
                      value: 'income',
                      child: Text('Revenus 📈'),
                    ),
                    DropdownMenuItem(
                      value: 'expense',
                      child: Text('Dépenses 📉'),
                    ),
                  ],
                  onChanged: (val) {
                    ref
                        .read(searchFiltersProvider.notifier)
                        .updateFilters(filters.copyWith(type: val));
                  },
                ),
                const SizedBox(width: 16),

                // Filtre Catégorie dynamique
                categoriesState.when(
                  data: (cats) => DropdownButton<int?>(
                    value: filters.categoryId,
                    hint: const Text('Catégorie'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Toutes catégories'),
                      ),
                      ...cats.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      ref
                          .read(searchFiltersProvider.notifier)
                          .updateFilters(
                            filters.copyWith(
                              categoryId: val,
                              clearCategory: val == null,
                            ),
                          );
                    },
                  ),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),
                const SizedBox(width: 16),

                // Filtre Période
                DropdownButton<DateFilter>(
                  value: filters.dateFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: DateFilter.all,
                      child: Text('Toute période'),
                    ),
                    DropdownMenuItem(
                      value: DateFilter.currentMonth,
                      child: Text('Ce mois'),
                    ),
                    DropdownMenuItem(
                      value: DateFilter.last30Days,
                      child: Text('30 derniers jours'),
                    ),
                  ],
                  onChanged: (val) {
                    ref
                        .read(searchFiltersProvider.notifier)
                        .updateFilters(filters.copyWith(dateFilter: val));
                  },
                ),
                const SizedBox(width: 16),

                // Tri
                DropdownButton<SortFilter>(
                  value: filters.sortFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: SortFilter.dateDesc,
                      child: Text('Plus récent'),
                    ),
                    DropdownMenuItem(
                      value: SortFilter.dateAsc,
                      child: Text('Plus ancien'),
                    ),
                    DropdownMenuItem(
                      value: SortFilter.amountDesc,
                      child: Text('Montant max'),
                    ),
                    DropdownMenuItem(
                      value: SortFilter.amountAsc,
                      child: Text('Montant min'),
                    ),
                  ],
                  onChanged: (val) {
                    ref
                        .read(searchFiltersProvider.notifier)
                        .updateFilters(filters.copyWith(sortFilter: val));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // --- LISTE DES RESULTATS ---
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Aucune transaction ne correspond aux filtres.",
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final item = filteredTransactions[index];
                      final isExpense = item.transaction.type == 'expense';
                      final categoryColor = Color(item.category.colorValue);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: categoryColor.withValues(
                              alpha: 0.15,
                            ),
                            foregroundColor: categoryColor,
                            child: Icon(_getIconData(item.category.icon)),
                          ),
                          title: Text(
                            item.transaction.comment ?? item.category.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
