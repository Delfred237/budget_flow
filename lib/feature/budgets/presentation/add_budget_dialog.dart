import 'package:budget_flow/feature/budgets/presentation/budget_controller.dart';
import 'package:budget_flow/feature/categories/presentation/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        // Éviter que le clavier cache le formulaire
        bottom: 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Définir un Budget Mensuel",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            categoriesState.when(
              data: (categories) => DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Catégorie concernée',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedCategoryId,
                items: categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) =>
                    val == null ? 'Sélectionnez une catégorie' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text("Erreur de chargement"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Limite mensuelle (FCFA)',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Entrez une limite';
                if (double.tryParse(value) == null) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ref
                      .read(budgetControllerProvider.notifier)
                      .saveBudget(
                        limit: double.parse(_limitController.text),
                        categoryId: _selectedCategoryId!,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Appliquer le budget",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
