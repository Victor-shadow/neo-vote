import 'package:neo_vote/features/voting/controller/voting_controller.dart';
import 'package:neo_vote/core/models/candidate_model.dart';
import 'package:neo_vote/presentation/common_widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class VoteConfirmationView extends ConsumerWidget {
  final String ballotId;
  final dynamic selection;
  final List<Candidate> candidates;

  const VoteConfirmationView({
    super.key,
    required this.ballotId,
    required this.selection,
    required this.candidates,
});

  @override
  Widget build(BuildContext context , WidgetRef ref){
    final theme = Theme.of(context);
    final voteState = ref.watch(votingControllerProvider);

    // Listen for state changes to show dialogs
    ref.listen<VoteSubmissionState>(votingControllerProvider, (prev, next){
      if(next.status == VoteSubmissionStatus.success){
        showDialog(
            context: context,
            barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Vote Cast Successfully!'),
          content: Text(
            'Your vote has been securely recorded.\nTransaction ID: ${next.transactionId}'),
                actions:[
                  TextButton(
              onPressed: (){
                //Pop all screens until the dashboard
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(votingControllerProvider.notifier).reset();

        },
            child: const Text('Ok'),
        ),
              ],
          ),
        );
      } else if(next.status == VoteSubmissionStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage ?? 'Failed to cast vote.'),
              backgroundColor: Colors.red),
        );

        //Allow user to retry
        ref.read(votingControllerProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Your Selection')),
      body: Padding(
          padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(Icons.lock_person, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'You have selected:',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            //Display the user Selection clearly
            _buildSelectionDisplay(context, theme),
            const SizedBox(height: 24),
            Text(
              'This action is final and cannot be undone. Your vote is anonymous and secure.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(flex: 2),
            PrimaryButton(
              text: 'Confirm and Cast Vote',
              isLoading: voteState.status == VoteSubmissionStatus.loading,
                onPressed: (){
                  ref.read(votingControllerProvider.notifier).castVote(ballotId, selection);
                },
            ),
            const SizedBox(height: 16),
            TextButton(
                onPressed: voteState.status == VoteSubmissionStatus.loading
                 ? null
                 : () => Navigator.of(context).pop(),
                child: const Text('Go Back and change'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionDisplay(BuildContext context, ThemeData theme){
    if(selection is String){
      //Single Choice
      final candidateName = candidates.firstWhere((c) => c.id == selection).name;
      return Text(
        candidateName,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      );
    } else if(selection is List<String>){
      //Ranked choice
      final rankedSelection = selection as List<String>;
      return Column(
        children: rankedSelection.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final candidateName = candidates.firstWhere((c) => c.id == entry.value).name;
          return Text(
            '$rank. $candidateName',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }
}