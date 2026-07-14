import 'package:budget_flow/feature/categories/presentation/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Listes de choix prédéfinis pour simplifier l'UI
  String _selectedIcon = 'local_atm';
  Color _selectedColor = Colors.blue;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'local_atm', 'icon': Icons.local_atm},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'alcohol', 'icon': Icons.local_drink},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'medical_services', 'icon': Icons.medical_services},
    {'name': 'movie', 'icon': Icons.movie},
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.pink,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        // Éviter que le clavier cache le formulaire
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
              "Nouvelle Catégorie",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la catégorie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_important_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ce champ est requis'
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              "Choisir une icône",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _availableIcons.map((item) {
                final isSelected = _selectedIcon == item['name'];
                return ChoiceChip(
                  label: Icon(
                    item['icon'],
                    color: isSelected ? Colors.white : null,
                  ),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedIcon = item['name'];
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              "Choisir une couleur",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 18,
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ref
                      .read(categoryControllerProvider.notifier)
                      .addCategory(
                        _nameController.text.trim(),
                        _selectedIcon,
                        _selectedColor.toARGB32(),
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
    );
  }
}
