import 'package:budget_flow/feature/categories/presentation/add_category_dialog.dart';
import 'package:budget_flow/feature/categories/presentation/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  // Fonction utilitaire pour faire correspondre le texte de la DB à l'icône Flutter réelle
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_atm':
        return Icons.local_atm;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'medical':
        return Icons.medical_services;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'alcohol':
        return Icons.local_drink;
      case 'other':
        return Icons.other_houses;
      default:
        return Icons.other_houses;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Catégories"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            builder: (context) => const AddCategoryDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Catégorie"),
      ),
      body: categoriesState.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text("Aucune catégorie enregistrée !"),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 éléments par ligne
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    1.3, // Gère la hauteur proportionnelle des cartes
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final category = list[index];
                final categoryColor = Color(category.colorValue);

                return Card(
                  elevation: 2,
                  color: categoryColor.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: categoryColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onLongPress: () {
                      // Option de suppression rapide sur un appui long
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Supprimer la catégorie ?"),
                          content: Text(
                            "Cela supprimera également toutes les transactions liées à ${category.name}.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(categoryControllerProvider.notifier)
                                    .removeCategory(category.id);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Supprimer",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: categoryColor,
                            foregroundColor: Colors.white,
                            child: Icon(_getIconData(category.icon)),
                          ),
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        error: (err, stack) =>
            Center(child: Text("Une erreur est survenue : $err")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
