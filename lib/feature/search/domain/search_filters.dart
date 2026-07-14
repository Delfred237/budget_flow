enum DateFilter { all, currentMonth, last30Days }

enum SortFilter { dateDesc, dateAsc, amountDesc, amountAsc }

class SearchFilters {
  final String query;
  final String type;
  final int? categoryId;
  final DateFilter dateFilter;
  final SortFilter sortFilter;

  const SearchFilters({
    this.query = '',
    this.type = 'all',
    this.categoryId,
    this.dateFilter = DateFilter.all,
    this.sortFilter = SortFilter.dateDesc,
  });

  // Méthode de copie pour faciliter la mise à jour partielle de l'état (Pattern Prototype)
  SearchFilters copyWith({
    String? query,
    String? type,
    int? categoryId,
    bool clearCategory = false,
    DateFilter? dateFilter,
    SortFilter? sortFilter,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      type: type ?? this.type,
      categoryId: clearCategory ? null : this.categoryId,
      dateFilter: dateFilter ?? this.dateFilter,
      sortFilter: sortFilter ?? this.sortFilter,
    );
  }
}
