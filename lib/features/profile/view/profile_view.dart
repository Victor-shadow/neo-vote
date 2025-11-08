// lib/features/profile/view/profile_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/features/auth/controller/auth_controller.dart';
import 'package:neo_vote/features/profile/widgets/profile_container.dart'; // CORRECTED
import 'package:neo_vote/features/profile/widgets/theme_switcher_widget.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // It's better to watch the provider that might change, like the user state
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final authNotifier = ref.read(authControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User info section
            ProfileContainer(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Name'),
                    subtitle: Text(
                      user?.name ?? 'Not available',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone Number'),
                    subtitle: Text(
                      user?.phoneNumber ?? 'Not available',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // App settings section
            ProfileContainer(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: const Text('Appearance'),
                    trailing: const ThemeSwitcherWidget(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('View Vote Receipts'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Use pushNamed for cleaner navigation
                      Navigator.of(context).pushNamed('/receipts');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              onPressed: () => authNotifier.logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
