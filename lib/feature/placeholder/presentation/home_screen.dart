import 'package:budget_flow/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.categories).watch();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final db = ref.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("BudgetFlow - Test DB")),
      body: Center(
        child: categoriesAsync.when(
          data: (categoriesList) {
            if (categoriesList.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("La base de données est vide !"),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await db
                          .into(db.categories)
                          .insert(
                            CategoriesCompanion.insert(
                              name: 'Alimentation 🍎',
                              icon: 'restaurant',
                              colorValue: Colors.orange.toARGB32(),
                            ),
                          );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Créer la catégorie Alimentation"),
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                final category = categoriesList[index];
                return ListTile(
                  title: Text(category.name),
                  leading: const Icon(Icons.category, color: Color(0xFF10B981)),
                  trailing: Text(category.colorValue.toString()),
                );
              },
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
