// lib/features/voting/widgets/ballot_options/ranked_choice_option.dart

import 'package:flutter/material.dart';
import 'package:neo_vote/core/models/candidate_model.dart';

/// A widget that allows users to rank a list of candidates by dragging and dropping them.
///
/// This stateful widget manages the order of candidates and reports the ranked
/// list of candidate IDs back to the parent widget via the [onChanged] callback.
class RankedChoiceOption extends StatefulWidget {
  final List<Candidate> candidates;
  final ValueChanged<List<String>> onChanged;

  const RankedChoiceOption({
    super.key,
    required this.candidates,
    required this.onChanged,
  });

  @override
  State<RankedChoiceOption> createState() => _RankedChoiceOptionState();
}

class _RankedChoiceOptionState extends State<RankedChoiceOption> {
  // A local copy of the candidates list to manage the ranking order.
  late List<Candidate> _rankedCandidates;

  @override
  void initState() {
    super.initState();
    // Initialize the local list with the candidates provided by the widget.
    _rankedCandidates = List.from(widget.candidates);
  }

  /// Handles the reordering of candidates in the list.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // This adjustment is necessary when moving an item down the list.
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      // Remove the item from its old position and insert it at the new one.
      final Candidate item = _rankedCandidates.removeAt(oldIndex);
      _rankedCandidates.insert(newIndex, item);

      // Notify the parent widget of the change with the new list of ranked IDs.
      widget.onChanged(_rankedCandidates.map((c) => c.id).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructional text for the user.
        Text(
          'Drag and drop candidates to rank them in order of preference.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        // The main reorderable list view.
        ReorderableListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // Disables scrolling within the list itself.
          itemCount: _rankedCandidates.length,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            final candidate = _rankedCandidates[index];
            // Each item is a Card for consistent UI.
            // The Key is crucial for Flutter to identify items during reordering.
            return Card(
              key: ValueKey(candidate.id),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                // Display the rank number (index + 1).
                leading: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                title: Text(candidate.name),
                // A handle to indicate that the item is draggable.
                trailing: const Icon(Icons.drag_handle_outlined),
              ),
            );
          },
        ),
      ],
    );
  }
}
