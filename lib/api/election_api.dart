// lib/api/election_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:neo_vote/core/models/election_model.dart';
import 'package:neo_vote/core/services/secure_storage_service.dart';
import 'package:neo_vote/core/utils/constants.dart';
import 'package:neo_vote/core/utils/failure.dart';
import 'package:neo_vote/core/utils/typedefs.dart';

/// API class responsible for all network requests related to elections.
class ElectionApi {
    final http.Client _client;
    final SecureStorageService _storageService;

    ElectionApi({
        required http.Client client,
        required SecureStorageService storageService,
    })  : _client = client,
            _storageService = storageService;

    /// A private helper to construct authenticated headers for API requests.
    /// Throws an exception if the auth token is not available.
    Future<Map<String, String>> _getHeaders() async {
        final token = await _storageService.getAuthToken();
        if (token == null) {
            // This is a critical failure, as requests can't be made without a token.
            throw Exception('Authentication token not found.');
        }
        return {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
        };
    }

    /// Fetches a list of currently active elections from the backend.
    ///
    /// Returns a `Right` with a list of `Election` models on success,
    /// or a `Left` with a `Failure` object on error.
    FutureEither<List<Election>> getActiveElections() async { // CORRECTED: Return type is now List<Election>
        try {
            final headers = await _getHeaders();
            final response = await _client
                .get(
                Uri.parse('${AppConstants.apiBaseUrl}/elections/active'),
                headers: headers,
            )
                .timeout(AppConstants.apiTimeout);

            if (response.statusCode == 200) {
                final data = jsonDecode(response.body) as List;
                // CORRECTED: Using .fromJson instead of the non-existent .fromMap
                final elections = data.map((e) => Election.fromJson(e)).toList();
                return right(elections);
            } else {
                // Handle non-200 status codes as server-side failures.
                return left(Failure('Server Error: ${response.statusCode}'));
            }
        } catch (e, st) {
            // Catch any other exceptions (e.g., timeout, network issues) and return a Failure.
            return left(Failure(e.toString(), st));
        }
    }
}
