import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/features/auth/controller/auth_controller.dart';
import 'package:neo_vote/features/auth/view/login_view.dart';
import 'package:neo_vote/features/dashboard/view/dashboard_view.dart';
import 'package:neo_vote/presentation/common_widgets/loading_spinner.dart';
import 'package:neo_vote/presentation/theme/app_theme.dart';
import 'package:neo_vote/presentation/theme/theme_provider.dart';

void main() {
  //Wrap the entire app in a ProviderScope
  runApp(
      const ProviderScope(child: NeoVoteApp()));
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
      themeMode: themeMode,
      //Define named routes for clean navigation
      routes: {
        '/dashboard': (context) => const DashboardView(),
        '/login': (context) => const LoginView(),
      },
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState){
    switch(authState.status){
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
        return const LoginView();
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
