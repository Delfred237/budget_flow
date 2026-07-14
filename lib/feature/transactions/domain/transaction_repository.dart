import 'package:budget_flow/core/database/app_database.dart';

abstract class TransactionRepository {
  Stream<List<TransactionWithCategory>> watchTransactionsWithCategory();
  Future<void> createTransaction({
    required double amount,
    required String? comment,
    required DateTime date,
    required String type,
    required int categoryId,
  });
  Future<void> deleteTransaction(int id);
}
