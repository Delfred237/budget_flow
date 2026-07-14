import 'package:budget_flow/core/database/app_database.dart';
import 'package:budget_flow/feature/search/domain/search_filters.dart';
import 'package:budget_flow/feature/transactions/presentation/transaction_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() {
    return SearchFilters();
  }

  void updateFilters(SearchFilters newFilters) {
    state = newFilters;
  }
}

// 1. Le Provider qui stocke l'état actuel de nos critères de filtre
final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, SearchFilters>(() {
      return SearchFiltersNotifier();
    });

// 2. Le Provider réactif qui fournit la liste des transactions filtrées
final filteredTransactionsProvider = Provider<List<TransactionWithCategory>>((
  ref,
) {
  // On écoute la liste complète des transactions
  final transactionsAsync = ref.watch(transactionControllerProvider);
  // On écoute les critères de recherche actuels
  final filters = ref.watch(searchFiltersProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final now = DateTime.now();

      return transactions.where((item) {
        // --- FILTRE TEXTUEL (Query) ---
        final matchesQuery =
            filters.query.isEmpty ||
            (item.transaction.comment?.toLowerCase().contains(
                  filters.query.toLowerCase(),
                ) ??
                false) ||
            item.category.name.toLowerCase().contains(
              filters.query.toLowerCase(),
            );

        // --- FILTRE PAR TYPE (Revenu/Dépense) ---
        final matchesType =
            filters.type == 'all' || item.transaction.type == filters.type;

        // --- FILTRE PAR CATEGORIE ---
        final matchesCategory =
            filters.categoryId == null ||
            item.transaction.categoryId == filters.categoryId;

        // --- FILTRE PAR DATE ---
        bool matchesDate = true;
        if (filters.dateFilter == DateFilter.currentMonth) {
          matchesDate =
              item.transaction.date.month == now.month &&
              item.transaction.date.year == now.year;
        } else if (filters.dateFilter == DateFilter.last30Days) {
          final difference = now.difference(item.transaction.date).inDays;
          matchesDate = difference >= 0 && difference <= 30;
        }

        return matchesQuery && matchesType && matchesCategory && matchesDate;
      }).toList()..sort((a, b) {
        // --- TRI DES RESULTATS ---
        switch (filters.sortFilter) {
          case SortFilter.dateAsc:
            return a.transaction.date.compareTo(b.transaction.date);
          case SortFilter.amountDesc:
            return b.transaction.amount.compareTo(a.transaction.amount);
          case SortFilter.amountAsc:
            return a.transaction.amount.compareTo(b.transaction.amount);
          case SortFilter.dateDesc:
          return b.transaction.date.compareTo(a.transaction.date);
        }
      });
    },
    loading: () => [],
    error: (_, _) => [],
  );
});
