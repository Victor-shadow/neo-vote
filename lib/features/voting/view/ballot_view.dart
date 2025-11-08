// lib/features/2_voting/view/ballot_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/core/models/ballot_model.dart';
import 'package:neo_vote/features/voting/controller/voting_controller.dart';
import 'package:neo_vote/features/voting/view/vote_confirmation_view.dart';
import 'package:neo_vote/features/voting/widgets/ballot_options/ranked_choice_option.dart';
import 'package:neo_vote/features/voting/widgets/ballot_options/single_choice_option.dart';
import 'package:neo_vote/features/voting/widgets/vote_timer_widget.dart';
import 'package:neo_vote/presentation/common_widgets/error_display_widget.dart';
import 'package:neo_vote/presentation/common_widgets/loading_spinner.dart';
import 'package:neo_vote/presentation/common_widgets/primary_button.dart';

class BallotView extends ConsumerStatefulWidget {
  final String electionId;
  const BallotView({super.key, required this.electionId});

  @override
  ConsumerState<BallotView> createState() => _BallotViewState();
}

class _BallotViewState extends ConsumerState<BallotView> {
  dynamic _selection;

  bool get _isSelectionValid {
    if (_selection == null) return false;
    if (_selection is String) return (_selection as String).isNotEmpty;
    if (_selection is List) return (_selection as List).isNotEmpty;
    return false;
  }

  // ignore: unused_element
  void _navigateToConfirmation(Ballot ballot) {
    if (!_isSelectionValid) return; // Safety check

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VoteConfirmationView(
          ballotId: ballot.id,
          selection: _selection!,
          candidates: ballot.candidates,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ballotAsync = ref.watch(ballotProvider(widget.electionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cast Your Vote'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24.0),
          child: VoteTimerWidget(),
        ),
      ),
      body: ballotAsync.when(
        data: (ballot) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text(
                      ballot.question,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _buildBallotWidget(ballot),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: PrimaryButton(
                    text: 'Review & Submit Vote', onPressed: () {}),
              ),
            ],
          );
        },
        loading: () => const LoadingSpinner(),
        error: (e, st) => ErrorDisplayWidget(
          errorMessage: "Failed to load the ballot for this election.",
          onRetry: () => ref.invalidate(ballotProvider(widget.electionId)),
        ),
      ),
    );
  }

  Widget _buildBallotWidget(Ballot ballot) {
    switch (ballot.type) {
      case BallotType.singleChoice:
        return SingleChoiceOption(
          candidates: ballot.candidates,
          selectedCandidate: _selection as String?,
          onChanged: (value) => setState(() => _selection = value),
        );
      case BallotType.rankedChoice:
        return RankedChoiceOption(
          candidates: ballot.candidates,
          onChanged: (value) => setState(() => _selection = value),
        );
      default:
        return const Center(
            child: Text('This ballot type is not currently supported.'));
    }
  }
}
