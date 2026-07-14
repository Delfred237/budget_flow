import 'dart:convert';

import 'package:budget_flow/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final AppDatabase _db;
  static const _currencyKey = 'selected_currency';
  static const _themeKey = 'selected_theme';

  SettingsRepository(this._db);

  // --- GESTION DE LA DEVISE ---
  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'FCFA';
  }

  Future<void> saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // --- GESTION DU THÈME ---
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Par défaut, on utilise le thème du système du téléphone ('system')
    return prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }

  // --- EXPORTATION DES DONNÉES EN JSON ---
  Future<String> exportBackup() async {
    // 1. Récupération de toutes les lignes des tables
    final categoriesList = await _db.select(_db.categories).get();
    final budgetsList = await _db.select(_db.budgets).get();
    final transactionsList = await _db.select(_db.transactions).get();

    // 2. Structuration dans une Map Dart
    final backupData = {
      'version': 1,
      'categories': categoriesList
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'icon': c.icon,
              'colorValue': c.colorValue,
            },
          )
          .toList(),
      'transactions': transactionsList
          .map(
            (t) => {
              'id': t.id,
              'amount': t.amount,
              'comment': t.comment,
              'date': t.date.toIso8601String(),
              'type': t.type,
              'categoryId': t.categoryId,
            },
          )
          .toList(),
      'budgets': budgetsList
          .map(
            (b) => {
              'id': b.id,
              'limitAmount': b.limitAmount,
              'categoryId': b.categoryId,
            },
          )
          .toList(),
    };

    // 3. Conversion en chaîne JSON bien formatée
    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  // --- IMPORTATION DES DONNÉES DEPUIS JSON ---
  Future<void> importBackup(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    await _db.transaction(() async {
      // 1. Nettoyer l'ancienne base pour éviter les conflits d'IDs
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.categories).go();

      // 2. Importer les catégories
      final categories = data['categories'] as List;
      for (final cat in categories) {
        await _db
            .into(_db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: Value(cat['id']),
                name: cat['name'],
                icon: cat['icon'],
                colorValue: cat['colorValue'],
              ),
            );
      }

      // 3. Importer les budgets
      final budgets = data['budgets'] as List;
      for (final b in budgets) {
        await _db
            .into(_db.budgets)
            .insert(
              BudgetsCompanion.insert(
                id: Value(b['id']),
                limitAmount: b['limitAmount'],
                categoryId: b['categoryId'],
              ),
            );
      }

      // 4. Importer les transactions
      final transactions = data['transactions'] as List;
      for (final t in transactions) {
        await _db
            .into(_db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: Value(t['id']),
                amount: t['amount'],
                comment: Value(t['comment']),
                date: DateTime.parse(t['date']),
                type: t['type'],
                categoryId: t['categoryId'],
              ),
            );
      }
    });
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db);
});
