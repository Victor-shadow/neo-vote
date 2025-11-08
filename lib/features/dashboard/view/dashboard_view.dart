// lib/features/1_dashboard/view/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/features/dashboard/controller/dashboard_controller.dart';
import 'package:neo_vote/features/dashboard/widgets/election_card.dart';
import 'package:neo_vote/features/dashboard/widgets/no_elections_widget.dart';
import 'package:neo_vote/presentation/common_widgets/error_display_widget.dart';
import 'package:neo_vote/presentation/common_widgets/loading_spinner.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final electionsAsyncValue = ref.watch(electionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Elections'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // Use ref.refresh for a cleaner way to trigger a refetch.
        onRefresh: () => ref.refresh(electionsProvider.future),
        child: electionsAsyncValue.when(
          data: (elections) {
            if (elections.isEmpty) {
              return const NoElectionsWidget();
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: elections.length,
              itemBuilder: (context, index) {
                return ElectionCard(election: elections[index]);
              },
            );
          },
          loading: () => const LoadingSpinner(),
          error: (error, stackTrace) => ErrorDisplayWidget(
            errorMessage: error.toString(),
            onRetry: () => ref.invalidate(electionsProvider),
          ),
        ),
      ),
    );
  }
}
