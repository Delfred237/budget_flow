import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // 1. Vérifier si le téléphone est équipé et si l'utilisateur a configuré la biométrie
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  // 2. Déclencher l'authentification biométrique
  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason:
            'Veuillez vous authentifier pour accéder à vos comptes',

        // Garde l'authentification active si l'app va en arrière-plan brièvement
        persistAcrossBackgrounding: true,
        biometricOnly:
            true, // Force uniquement la biométrie (pas de code PIN de secours si non souhaité)

        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Sécurité BudgetFlow',
            signInHint: 'Vérifiez votre identité',
            cancelButton: 'Annuler',
          ),
          IOSAuthMessages(
            cancelButton: 'Annuler',
          ),
        ],
      );
      return didAuthenticate;
    } on PlatformException {
      return false;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});
