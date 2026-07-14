import 'package:budget_flow/feature/categories/presentation/category_controller.dart';
import 'package:budget_flow/feature/transactions/presentation/transaction_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  String _transactionType = 'expense'; // 'expense' ou 'income'
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryControllerProvider);

    return Padding(
      padding: EdgeInsetsGeometry.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Nouvelle Transaction",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Sélecteur Type: Revenu / Dépense (Material 3 SegmentedButton)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Dépense'),
                    icon: Icon(Icons.trending_down),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Revenu'),
                    icon: Icon(Icons.trending_up),
                  ),
                ],
                selected: {_transactionType},
                onSelectionChanged: (selected) {
                  setState(() {
                    _transactionType = selected.first;
                  });
                },
              ),
              const SizedBox(
                height: 16,
              ),

              // Champ Montant
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: Icon(Icons.monetization_on_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Entrez un montant';
                  if (double.tryParse(value) == null) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélecteur de Catégorie branché sur Drift
              categoriesState.when(
                data: (categories) {
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    initialValue: _selectedCategoryId,
                    items: categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                    validator: (val) =>
                        val == null ? 'Sélectionnez une catégorie' : null,
                  );
                },
                error: (_, _) => Text("Erreur de chargement des catégories"),
                loading: () => const LinearProgressIndicator(),
              ),
              const SizedBox(
                height: 16,
              ),

              // Commentaire (Optionnel)
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Note / Commentaire',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 16,
              ),

              // Sélecteur de Date
              ListTile(
                title: Text(
                  "Date : ${DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate)}",
                ),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: () => _selectDate(context),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _transactionType == 'expense'
                      ? Colors.redAccent
                      : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(transactionControllerProvider.notifier)
                        .addTransaction(
                          amount: double.parse(_amountController.text),
                          comment: _commentController.text.trim().isEmpty
                              ? null
                              : _commentController.text,
                          date: _selectedDate,
                          type: _transactionType,
                          categoryId: _selectedCategoryId!,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Enregistrer",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
