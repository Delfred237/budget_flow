import 'package:budget_flow/core/database/app_database.dart';
import 'package:budget_flow/feature/transactions/domain/transaction_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _db;

  TransactionRepositoryImpl(this._db);

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsWithCategory() {
    // Jointure SQL : SELECT * FROM transactions INNER JOIN categories ON ...
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ]);

    // Trie par date décroissante pour afficher les plus récentes en premier
    query.orderBy([OrderingTerm.desc(_db.transactions.date)]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => TransactionWithCategory(
              transaction: row.readTable(_db.transactions),
              category: row.readTable(_db.categories),
            ),
          )
          .toList();
    });
  }

  @override
  Future<void> createTransaction({
    required double amount,
    required String? comment,
    required DateTime date,
    required String type,
    required int categoryId,
  }) {
    return _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            amount: amount,
            comment: Value(comment),
            date: date,
            type: type,
            categoryId: categoryId,
          ),
        );
  }

  @override
  Future<void> deleteTransaction(int id) {
    return (_db.delete(_db.transactions)..where((tbl) => tbl.id.equals(id))).go();
  }
}

// Provider de distribution du repository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db);
});