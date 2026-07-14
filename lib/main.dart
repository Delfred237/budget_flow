import 'package:budget_flow/core/notifications/notification_service.dart';
import 'package:budget_flow/core/routing/app_router.dart';
import 'package:budget_flow/core/theme/app_theme.dart';
import 'package:budget_flow/feature/settings/presentation/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des formats linguistiques régionaux
  await initializeDateFormatting('fr-FR', null);

  // Initialisation du container Riverpod pour lire les providers en dehors des widgets
  final container = ProviderContainer();
  await container.read(notificationServiceProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BudgetFlowApp(),
    ),
  );
}

class BudgetFlowApp extends ConsumerWidget {
  const BudgetFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeState = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'BudgetFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeModeState.value ?? ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
