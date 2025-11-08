// lib/core/models/candidate_model.dart

import 'package:equatable/equatable.dart';

/// Represents a candidate in an election.
///
/// This model contains the essential information about a single candidate,
/// including a unique identifier, their name, and an optional description.
/// It uses the `equatable` package to simplify value-based equality checks.
class Candidate extends Equatable {
    /// A unique identifier for the candidate (e.g., a UUID).
    final String id;

    /// The full name of the candidate.
    final String name;

    /// An optional, longer description for the candidate, which could include
    /// their platform, biography, or other relevant information.
    final String? description;

    const Candidate({
        required this.id,
        required this.name,
        this.description,
    });

    /// The properties used by `Equatable` to determine if two instances are equal.
    @override
    List<Object?> get props => [id, name, description];

    /// Creates a `Candidate` instance from a JSON map.
    ///
    /// This factory constructor is useful for deserializing data fetched from an API.
    /// It provides default values for safety, though `id` and `name` are expected.
    factory Candidate.fromJson(Map<String, dynamic> json) {
        return Candidate(
            id: json['id'] as String? ?? '',
            name: json['name'] as String? ?? 'Unknown Candidate',
            description: json['description'] as String?,
        );
    }
}
