import 'dart:async';

import 'package:budget_flow/core/database/app_database.dart';
import 'package:budget_flow/feature/categories/data/category_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryController extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    // Abonnement au flux de la base de données.
    // Mettre l'UI a jour automatiquement a chaue changement de la table.
    final repo = ref.watch(categoryRepositoryProvider);

    final controller = StreamController<List<Category>>();
    final subscription = repo.watchCategories().listen((categories) {
      state = AsyncValue.data(categories);
    });

    ref.onDispose(() {
      subscription.cancel();
      controller.close();
    });

    // Récupération de la première valeur immédiate
    return repo.watchCategories().first;
  }

  Future<void> addCategory(String name, String icon, int colorValue) async {
    state = const AsyncValue.loading();

    try {
      await ref
          .read(categoryRepositoryProvider)
          .createCategory(name, icon, colorValue);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeCategory(int id) async {
    try {
      await ref.read(categoryRepositoryProvider).deleteCategory(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Enregistrement du contrôleur auprès de Riverpod
final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, List<Category>>(() {
      return CategoryController();
    });
