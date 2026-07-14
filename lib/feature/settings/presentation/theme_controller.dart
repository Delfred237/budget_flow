import 'package:budget_flow/feature/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ThemeController extends AsyncNotifier<ThemeMode> {
  @override
  FutureOr<ThemeMode> build() async {
    final themeString = await ref
        .watch(settingsRepositoryProvider)
        .getThemeMode();
    return _mapStringToThemeMode(themeString);
  }

  Future<void> updateThemeMode(ThemeMode newMode) async {
    state = const AsyncValue.loading();
    try {
      final themeString = _mapThemeModeToString(newMode);
      await ref.read(settingsRepositoryProvider).saveThemeMode(themeString);
      state = AsyncValue.data(newMode);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  ThemeMode _mapStringToThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _mapThemeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}

final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, ThemeMode>(() {
      return ThemeController();
    });
