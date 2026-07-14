import 'dart:io';

import 'package:budget_flow/feature/settings/data/settings_repository.dart';
import 'package:budget_flow/feature/settings/presentation/settings_controller.dart';
import 'package:budget_flow/feature/settings/presentation/theme_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Action d'exportation
  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final jsonString = await ref
          .read(settingsRepositoryProvider)
          .exportBackup();

      // Enregistrer temporairement le fichier pour le partager
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/budgetflow_backup.json');
      await file.writeAsString(jsonString);

      // Ouvrir la feuille de partage native
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Sauvegarde de mes dépenses BudgetFlow',
      );

      if (result.status == ShareResultStatus.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Exportation réussie ! 🎉")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur d'exportation : $e")),
        );
      }
    }
  }

  // Action d'importation
  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonContent = await file.readAsString();

        await ref.read(settingsRepositoryProvider).importBackup(jsonContent);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sauvegarde restaurée avec succès ! 🔄"),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'importation : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(settingsControllerProvider);
    final themeState = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          // --- SECTION DEVISE ---
          ListTile(
            title: Text(
              "Général",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          currencyState.when(
            data: (currentCurrency) => ListTile(
              leading: const Icon(Icons.monetization_on_outlined),
              title: const Text("Devise de l'application"),
              subtitle: Text("Actuelle : $currentCurrency"),
              trailing: DropdownButton<String>(
                value: currentCurrency,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'FCFA', child: Text('FCFA (CFA)')),
                  DropdownMenuItem(value: '€', child: Text('Euro (€)')),
                  DropdownMenuItem(value: '\$', child: Text('Dollar (\$)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateCurrency(val);
                  }
                },
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text("Erreur de devise"),
          ),
          const Divider(),

          // Sélecteur de Thème
          themeState.when(
            data: (currentThemeMode) => ListTile(
              leading: Icon(
                currentThemeMode == ThemeMode.dark
                    ? Icons.dark_mode_outlined
                    : currentThemeMode == ThemeMode.light
                    ? Icons.light_mode_outlined
                    : Icons.settings_brightness_outlined,
              ),
              title: const Text("Thème de l'application"),
              subtitle: Text(
                currentThemeMode == ThemeMode.dark
                    ? "Sombre"
                    : currentThemeMode == ThemeMode.light
                    ? "Clair"
                    : "Système (Automatique)",
              ),
              trailing: DropdownButton<ThemeMode>(
                value: currentThemeMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Système'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Clair'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Sombre'),
                  ),
                ],
                onChanged: (newMode) {
                  if (newMode != null) {
                    ref
                        .read(themeControllerProvider.notifier)
                        .updateThemeMode(newMode);
                  }
                },
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text("Erreur de chargement du thème"),
          ),

          const Divider(),

          // --- SECTION SAUVEGARDE & SECURITE ---
          ListTile(
            title: Text(
              "Sauvegarde & Sécurité",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text("Exporter mes données"),
            subtitle: const Text("Générer un fichier de sauvegarde JSON"),
            onTap: () => _exportData(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.file_download_outlined),
            title: const Text("Importer des données"),
            subtitle: const Text("Restaurer depuis un fichier de sauvegarde"),
            onTap: () => _importData(context, ref),
          ),
        ],
      ),
    );
  }
}
