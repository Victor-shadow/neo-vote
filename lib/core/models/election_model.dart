// TODO Implement this library.
// lib/core/models/election_model.dart

import 'package:equatable/equatable.dart';/// Represents an election available for voting.
///
/// This model holds the core details of an election, including its unique
/// identifier, title, and the deadline for voting. It uses `equatable`
/// for straightforward value-based comparisons.
class Election extends Equatable {
  /// A unique identifier for the election.
  final String id;

  /// The official title or question of the election.
  final String title;

  /// The exact date and time when voting for this election closes.
  final DateTime endTime;

  const Election({
    required this.id,
    required this.title,
    required this.endTime,
  });

  /// The properties used by `Equatable` for equality checks.
  @override
  List<Object?> get props => [id, title, endTime];

  /// Creates an `Election` instance from a JSON map.
  ///
  /// This factory is essential for parsing API responses. It includes robust
  /// error handling for missing or malformed data, such as parsing date strings.
  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Election',
      // Safely parse the endTime, falling back to the current time if invalid.
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
