// lib/features/auth/view/otp_view.dart

import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/features/auth/controller/auth_controller.dart';
import 'package:neo_vote/presentation/common_widgets/primary_button.dart';

class OtpView extends ConsumerWidget {
  final String phoneNumber;
  const OtpView({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final otpController = TextEditingController();

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      } else if (next.status == AuthStatus.requiresOtp && next.errorMessage != null) {
        // Show error if OTP was wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Number')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter the 6-digit code sent to',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                phoneNumber,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  counterText: "",
                ),
                style: const TextStyle(fontSize: 24, letterSpacing: 16),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Verify & Proceed',
                isLoading: authState.status == AuthStatus.loading,
                onPressed: () {
                  if (otpController.text.length == 6) {
                    authController.verifyOtp(phoneNumber, otpController.text);
                  }
                },
              ),
              TextButton(
                onPressed: authState.status == AuthStatus.loading
                    ? null
                    : () {
                  authController.loginWithPhoneNumber(phoneNumber);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A new code has been sent.')),
                  );
                },
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
