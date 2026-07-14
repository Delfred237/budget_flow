import 'package:budget_flow/core/database/app_database.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();

  Future<void> createCategory(String name, String icon, int colorValue);

  Future<void> deleteCategory(int id);
}
