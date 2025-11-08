import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

// A button that initiates a biometric authentication prompt (fingerprint/face).
class BiometricPromptButton extends StatelessWidget {
  final VoidCallback onAuthenticated;

  const BiometricPromptButton({
    super.key,
    required this.onAuthenticated,
  });

  Future<void> _authenticate(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticate =
        await auth.canCheckBiometrics || await auth.isDeviceSupported();

    // Check if the widget is still in the tree before using its context.
    if (!context.mounted) return;

    if (!canAuthenticate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication not available.')),
      );
      return;
    }

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to log into NeoVote',
        // The 'const' keyword is also removed as the real constructor isn't const.
        // options: AuthenticationOptions(
        //   stickyAuth: true, // Keep prompt open on failure
        //   biometricOnly: true, // Do not allow device PIN
        // ),
      );

      // Another check after the authentication async gap.
      if (context.mounted && didAuthenticate) {
        onAuthenticated();
      }
    } on PlatformException catch (e) {
      // Final check before showing a potential error.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.fingerprint),
      label: const Text('Login with Biometrics'),
      onPressed: () => _authenticate(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

