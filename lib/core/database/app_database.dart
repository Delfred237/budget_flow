import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 1. AJOUT DE L'IMPORT POUR LES DOSSIERS DU TÉLÉPHONE
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// --- DEFINITION DES TABLES ---

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text().withLength(min: 1, max: 20)();
  IntColumn get colorValue => integer()();
}

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get comment => text().nullable().withLength(min: 1, max: 200)();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text().withLength(min: 1, max: 10)();

  IntColumn get categoryId => integer().references(
    Categories,
    #id,
    onDelete: KeyAction.cascade,
  )();
}

@DataClassName('Budget')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get limitAmount => real()();

  IntColumn get categoryId => integer().references(
    Categories,
    #id,
    onDelete: KeyAction.cascade,
  )();
}

class TransactionWithCategory {
  final Transaction transaction;
  final Category category;

  TransactionWithCategory({
    required this.transaction,
    required this.category,
  });
}

// --- CREATION DE LA BASE DE DONNEES ---

@DriftDatabase(tables: [Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'budget_flow.sqlite'));

    // if (await file.exists()) {
    //   await file.delete();
    // }

    return NativeDatabase.createInBackground(file);
  }); // 2. CORRECTION : Ajout du point-virgule ici
}

// --- INTEGRATION RIVERPOD ---

// 3. CORRECTION : Suppression de la flèche '=>' pour exécuter le bloc correctement
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  ref.onDispose(() => db.close());
  return db; // 4. CORRECTION : Ajout du point-virgule ici
});
