// TODO Implement this library.
// lib/core/models/receipt_model.dart

import 'package:equatable/equatable.dart';

/// Represents a proof of a vote that has been cast.
///
/// This model acts as a digital receipt for a user's past vote, containing
/// details about the election, the date the vote was cast, and the unique
/// transaction ID for verification on the blockchain.
class Receipt extends Equatable {
  /// The title of the election the user voted in.
  final String electionTitle;

  /// The unique, verifiable transaction ID from the blockchain.
  final String transactionId;

  /// The date and time when the vote was successfully recorded.
  final DateTime dateCasted;

  const Receipt({
    required this.electionTitle,
    required this.transactionId,
    required this.dateCasted,
  });

  /// The properties used for value equality.
  @override
  List<Object?> get props => [electionTitle, transactionId, dateCasted];

  /// Creates a `Receipt` instance from a JSON map.
  ///
  /// This factory constructor is designed to safely parse data from an API,
  /// with fallbacks for missing fields and safe date parsing.
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      electionTitle: json['electionTitle'] as String? ?? 'Unknown Election',
      transactionId: json['transactionId'] as String? ?? 'N/A',
      dateCasted: json['dateCasted'] != null
          ? DateTime.tryParse(json['dateCasted'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
