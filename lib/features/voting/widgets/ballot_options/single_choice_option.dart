// lib/features/voting/widgets/ballot_options/single_choice_option.dart

import 'package:flutter/material.dart';
import 'package:neo_vote/core/models/candidate_model.dart';

class SingleChoiceOption extends StatelessWidget {
  final List<Candidate> candidates;
  final String? selectedCandidate;
  final ValueChanged<String?> onChanged;

  const SingleChoiceOption({
    super.key,
    required this.candidates,
    required this.selectedCandidate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // Map each candidate to a selectable Card with a RadioListTile.
      children: candidates.map((candidate) {
        final bool isSelected = selectedCandidate == candidate.id;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          // CORRECTED: RadioListTile<String> syntax fixed.
          child: RadioListTile<String>(
            title: Text(candidate.name,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: candidate.description != null
                ? Text(candidate.description!)
                : null,
            value: candidate.id,
            groupValue: selectedCandidate,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        );
      }).toList(),
    );
  }
}
