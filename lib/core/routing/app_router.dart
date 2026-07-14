import 'package:budget_flow/feature/budgets/presentation/budget_list_screen.dart';
import 'package:budget_flow/feature/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_flow/feature/search/presentation/search_screen.dart';
import 'package:budget_flow/feature/settings/presentation/settings_screen.dart';
import 'package:budget_flow/feature/splash/presentation/splash_screen.dart';
import 'package:budget_flow/feature/statistic/presentation/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 1. Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    // 2. Dashboard (Redéfini sur '/') pour que context.go('/') fonctionne
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    // Route Recherche avec transition animée (Slide de bas en haut)
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(0.0, 1.0), // Commence en bas
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
      ),
    ),
    // Route Stats avec transition animée (Fade transition)
    GoRoute(
      path: '/stats',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const StatsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    // Route Budgets
    GoRoute(
      path: '/budgets',
      builder: (context, state) => const BudgetListScreen(),
    ),
    // Route Settings
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
