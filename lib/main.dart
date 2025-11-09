import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neo_vote/features/auth/controller/auth_controller.dart';
import 'package:neo_vote/features/auth/view/signup_view.dart';
import 'package:neo_vote/features/dashboard/view/dashboard_view.dart';
import 'package:neo_vote/presentation/common_widgets/loading_spinner.dart';
import 'package:neo_vote/presentation/theme/app_theme.dart';
import 'package:neo_vote/presentation/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //Initialize firebase
  //Wrap the entire app in a ProviderScope
  runApp(const ProviderScope(child: NeoVoteApp()));
}

class NeoVoteApp extends ConsumerWidget {
  const NeoVoteApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watch the theme provider rebuild the MaterialAppUI when the theme is selected
    final themeMode = ref.watch(themeNotifierProvider);
    //watch the auth Controller determine which main view to show
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Neo Vote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode == ThemeMode.system
          ? ThemeMode.dark
          : themeMode, //default to Dark
      //Define named routes for clean navigation
      routes: {
        '/dashboard': (context) => const DashboardView(),
        '/login': (context) => const SignupView(),
      },
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      //While the app is initializing (checking for a token), show a loading screen
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(body: LoadingSpinner());

      //If the user is authenticated, navigate to the main dashboard
      case AuthStatus.authenticated:
        return const DashboardView();

      // If authenticated or an error occurred during token validation, show login screen
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      default:
        return const SignupView();
    }
  }
}
