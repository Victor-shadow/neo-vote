import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/features/auth/controller/auth_controller.dart';
import 'package:neo_vote/features/auth/view/otp_view.dart';
import 'package:neo_vote/features/auth/widgets/biometric_prompt_button.dart';
import 'package:neo_vote/presentation/common_widgets/loading_spinner.dart';
import 'package:neo_vote/presentation/common_widgets/primary_button.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final phoneNumberController = TextEditingController();

    ref.listen<AuthState>(authControllerProvider, (previous, next){
      if(next.status == AuthStatus.requiresOtp){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OtpView(phoneNumber: phoneNumberController.text),
        ));
      } else if (next.status == AuthStatus.error && previous?.status == AuthStatus.loading){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'An Error occurred'),
              backgroundColor: Colors.red,
              ),
            );
      }
    });

    if (authState.status == AuthStatus.loading && authState.user == null){
      return const Scaffold(body: LoadingSpinner());
    }

    return Scaffold(
      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.how_to_vote_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to NeoVote',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure, transparent and easy voting',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_android),
                      hintText: 'e.g. , +254',
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                      text: 'Send Code',
                      isLoading: authState.status == AuthStatus.loading,
                      onPressed: () {
                        if (phoneNumberController.text.isNotEmpty){
                          authController.loginWithPhoneNumber(phoneNumberController.text);
                        }
                      },
                  ),
                  const SizedBox(height: 16),
                  BiometricPromptButton(
                    onAuthenticated: (){
                      authController.loginWithBiometricToken();
                    }
                  )
                ],
              )
            ),
          ),
      ),
    );

  }

}