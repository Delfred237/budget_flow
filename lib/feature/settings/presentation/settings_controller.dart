import 'package:budget_flow/feature/settings/data/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsController extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return ref.watch(settingsRepositoryProvider).getCurrency();
  }

  Future<void> updateCurrency(String newCurrency) async {
    state = const AsyncValue.loading();
    try {
      await ref.watch(settingsRepositoryProvider).saveCurrency(newCurrency);
      state = AsyncValue.data(newCurrency);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, String>(() {
      return SettingsController();
    });
