// lib/api/vote_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:neo_vote/core/models/ballot_model.dart';
import 'package:neo_vote/core/models/receipt_model.dart';
import 'package:neo_vote/core/services/secure_storage_service.dart';
import 'package:neo_vote/core/utils/constants.dart';
import 'package:neo_vote/core/utils/failure.dart';
import 'package:neo_vote/core/utils/typedefs.dart';

/// API class responsible for all network requests related to voting and receipts.
class VoteApi {
  final http.Client _client;
  final SecureStorageService _storageService;

  VoteApi({
    required http.Client client,
    required SecureStorageService storageService,
  })  : _client = client,
        _storageService = storageService;

  /// A private helper to construct authenticated headers for API requests.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetches the ballot for a specific election.
  FutureEither<Ballot> getBallot(String electionId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
        Uri.parse('${AppConstants.apiBaseUrl}/elections/$electionId/ballot'),
        headers: headers,
      )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // CORRECTED: Using .fromJson to parse the Ballot object.
        return right(Ballot.fromJson(data));
      } else {
        return left(Failure('Failed to load ballot: ${response.statusCode}'));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  /// Casts a vote for a given ballot and returns a transaction ID on success.
  FutureEither<String> castVote(String ballotId, dynamic selection) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .post(
        Uri.parse('${AppConstants.apiBaseUrl}/vote/cast'),
        headers: headers,
        body: jsonEncode({
          'ballotId': ballotId,
          'selection': selection, // Can be a String or List<String>
        }),
      )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) { // Also accept 201 Created
        final data = jsonDecode(response.body);
        final transactionId = data['transactionId'] as String;
        return right(transactionId);
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to cast vote.';
        return left(Failure(error));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  /// Fetches a list of all past vote receipts for the authenticated user.
  FutureEither<List<Receipt>> getVoteReceipts() async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
        Uri.parse('${AppConstants.apiBaseUrl}/receipts'),
        headers: headers,
      )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        // CORRECTED: Using .fromJson for each item in the list.
        final receipts = data.map((r) => Receipt.fromJson(r)).toList();
        return right(receipts);
      } else {
        return left(Failure('Failed to fetch receipts: ${response.statusCode}'));
      }
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
