// lib/core/providers/api_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:neo_vote/api/auth_api.dart';
import 'package:neo_vote/api/election_api.dart';
import 'package:neo_vote/api/vote_api.dart';
import 'package:neo_vote/core/services/secure_storage_service.dart';

// Provider for the HTTP client, making a single instance available to the app.
final httpClientProvider = Provider((ref) => http.Client());

// Provider for the SecureStorageService, which handles reading/writing the auth token.
final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

// Provider for AuthApi.
// This API handles sending/verifying OTPs and fetching the user profile.
final authApiProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  return AuthApi(client: client);
});

// Provider for ElectionApi.
// This API needs an HTTP client for network requests and secure storage to get the auth token.
final electionApiProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  final storageService = ref.watch(secureStorageServiceProvider); // This dependency was missing
  return ElectionApi(
    client: client,
    storageService: storageService,
  );
});

// Provider for VoteApi.
// This API also needs an HTTP client and secure storage for authenticated requests.
final voteApiProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  final storageService = ref.watch(secureStorageServiceProvider); // This dependency was missing
  return VoteApi(
    client: client,
    storageService: storageService,
  );
});
