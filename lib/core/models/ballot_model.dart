// lib/core/models/ballot_model.dart

import 'package:equatable/equatable.dart';
import 'package:neo_vote/core/models/candidate_model.dart';

/// Enum to define the supported types of ballots for strong typing.
enum BallotType {
    singleChoice,
    rankedChoice,
    unknown,
}

/// Represents a ballot for a specific election.
///
/// This model contains all the necessary information for the voting interface,
/// including the ballot question, a list of candidates, and the ballot type.
class Ballot extends Equatable {
    final String id;
    final String question; // Renamed from 'title' for clarity in context
    final List<Candidate> candidates;
    final BallotType type;

    const Ballot({
        required this.id,
        required this.question,
        required this.candidates,
        required this.type,
    });

    @override
    List<Object?> get props => [id, question, candidates, type];

    /// Creates a `Ballot` instance from a JSON map.
    ///
    /// This factory safely parses API data, including a list of candidates
    /// and determines the `BallotType` from a string value.
    factory Ballot.fromJson(Map<String, dynamic> json) {
        var candidateList = json['candidates'] as List? ?? [];
        List<Candidate> candidates =
        candidateList.map((c) => Candidate.fromJson(c)).toList();

        BallotType type;
        switch (json['type'] as String?) {
            case 'single_choice':
                type = BallotType.singleChoice;
                break;
            case 'ranked_choice':
                type = BallotType.rankedChoice;
                break;
            default:
                type = BallotType.unknown;
        }

        return Ballot(
            id: json['id'] as String? ?? '',
            // The ballot question is often stored under 'title' or 'question'.
            question: json['question'] as String? ?? json['title'] as String? ?? 'No question provided',
            candidates: candidates,
            type: type,
        );
    }
}
