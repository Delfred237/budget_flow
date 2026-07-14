import 'package:budget_flow/core/database/app_database.dart';
import 'package:budget_flow/feature/budgets/domain/budget_repository.dart';
import 'package:budget_flow/feature/budgets/domain/budget_with_category.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

class BudgetRepositoryImpl extends BudgetRepository {
  final AppDatabase _db;

  BudgetRepositoryImpl(this._db);

  @override
  Stream<List<BudgetWithCategory>> watchBudgetsWithCategory() {
    // 1. On écoute la table des budgets jointe aux catégories
    final budgetStream = _db.select(_db.budgets).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.budgets.categoryId),
      ),
    ]).watch();

    // 2. On écoute aussi les transactions pour recalculer dès qu'une dépense change
    final transactionStream = _db.select(_db.transactions).watch();

    // 3. On combine les deux streams pour avoir une réactivité totale !
    return Rx.combineLatest2<
      List<TypedResult>,
      List<Transaction>,
      List<BudgetWithCategory>
    >(budgetStream, transactionStream, (budgetRows, transactions) {
      final now = DateTime.now();

      return budgetRows.map((row) {
        final budget = row.readTable(_db.budgets);
        final category = row.readTable(_db.categories);

        // On somme les transactions "dépenses" de ce mois pour cette catégorie
        final spent = transactions
            .where(
              (t) =>
                  t.categoryId == category.id &&
                  t.type == 'expense' &&
                  t.date.month == now.month &&
                  t.date.year == now.year,
            )
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        return BudgetWithCategory(
          budget: budget,
          category: category,
          amountSpent: spent,
        );
      }).toList();
    });
  }

  @override
  Future<void> setBudget({
    required double limitAmount,
    required int categoryId,
  }) async {
    // Si un budget existe déjà pour cette catégorie, on le met à jour, sinon on le crée (Upsert)
    await _db
        .into(_db.budgets)
        .insertOnConflictUpdate(
          BudgetsCompanion.insert(
            limitAmount: limitAmount,
            categoryId: categoryId,
          ),
        );
  }

  @override
  Future<void> deleteBudget(int id) {
    return (_db.delete(_db.budgets)..where((tbl) => tbl.id.equals(id))).go();
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(db);
});
