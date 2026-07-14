import 'package:budget_flow/core/database/app_database.dart';
import 'package:budget_flow/feature/categories/domain/category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  @override
  Stream<List<Category>> watchCategories() {
    return _db.select(_db.categories).watch();
  }

  @override
  Future<void> createCategory(String name, String icon, int colorValue) {
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name,
            icon: icon,
            colorValue: colorValue,
          ),
        );
  }

  @override
  Future<void> deleteCategory(int id) {
    return (_db.delete(_db.categories)..where((tbl) => tbl.id.equals(id))).go();
  }
}

// Provider pour distribuer notre Repository à travers l'application
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(db);
});
