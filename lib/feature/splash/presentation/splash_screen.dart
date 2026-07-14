import 'dart:async';

import 'package:budget_flow/core/security/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation d'apparition du logo
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward().then((_) {
      // Une fois l'animation terminée, on lance la vérification de sécurité
      _startAuthProcess();
    });

    // Redirection automatique vers le Dashboard après 2.5 secondes
    // Timer(const Duration(milliseconds: 3000), () {
    //   if (mounted) {
    //     context.go('/'); // Utilise GoRouter pour aller à l'accueil
    //   }
    // });
  }

  Future<void> _startAuthProcess() async {
    final bioService = ref.read(biometricServiceProvider);
    final isAvailable = await bioService.isBiometricAvailable();

    if (isAvailable) {
      final success = await bioService.authenticate();
      if (success && mounted) {
        context.go('/'); // Redirection vers le Dashboard
      } else {
        setState(() {
          _showRetryButton = true; // Affiche un bouton si l'utilisateur annule
        });
      }
    } else {
      // Si l'appareil n'a pas de biométrie, on laisse entrer directement
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Un léger dégradé élégant basé sur ton thème
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)]
                : [const Color(0xFFE8F5E9), Colors.white],
          ),
        ),

        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icone ou Logo Central
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                // Titre de l'application
                const Text(
                  'BudgetFlow',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Slogan ou sous-titre
                Text(
                  'Prenez le contrôle de vos finances',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),
                // Indicateur de chargement discret
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Coffre-fort financier sécurisé',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(flex: 2),

                // Zone d'action dynamique (Bouton de retry OU indicateur de chargement)
                SizedBox(
                  height: 100,
                  child: _showRetryButton
                      ? Column(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _showRetryButton = false);
                                _startAuthProcess();
                              },
                              icon: Icon(
                                Icons.fingerprint,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              label: Text(
                                'Déverrouiller l\'application',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
