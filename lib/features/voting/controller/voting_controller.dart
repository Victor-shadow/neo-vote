// lib/features/voting/controller/voting_controller.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http; // CORRECTED: Import with a prefix
import 'package:neo_vote/api/vote_api.dart';
import 'package:neo_vote/core/models/ballot_model.dart';
import 'package:neo_vote/core/services/secure_storage_service.dart';

// --- State Definitions ---

enum VoteSubmissionStatus {
  initial,
  loading,
  success,
  error,
}

class VoteSubmissionState extends Equatable {
  final VoteSubmissionStatus status;
  final String? transactionId;
  final String? errorMessage;

  const VoteSubmissionState({
    this.status = VoteSubmissionStatus.initial,
    this.transactionId,
    this.errorMessage,
  });

  VoteSubmissionState copyWith({
    VoteSubmissionStatus? status,
    String? transactionId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoteSubmissionState(
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactionId, errorMessage];
}

// --- Providers ---

// Provider for a basic http client (should be defined in a central providers file)
final httpClientProvider = Provider((ref) => http.Client());

// Provider for your SecureStorageService (should also be defined centrally)
final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

/// Provider for the VoteApi, correctly constructed with its dependencies.
final voteApiProvider = Provider((ref) => VoteApi(
  client: ref.watch(httpClientProvider),
  storageService: ref.watch(secureStorageServiceProvider),
));

/// Provider to fetch the ballot for a given election using the correct API method.
final ballotProvider = FutureProvider.autoDispose.family<Ballot, String>((ref, electionId) async {
  final voteApi = ref.watch(voteApiProvider);
  final result = await voteApi.getBallot(electionId);
  return result.fold(
        (failure) => throw failure.message,
        (ballot) => ballot,
  );
});

/// Controller for managing the vote submission state.
final votingControllerProvider = StateNotifierProvider.autoDispose<VotingController, VoteSubmissionState>(
      (ref) => VotingController(
    ref.watch(voteApiProvider),
  ),
);

// --- Controller ---

class VotingController extends StateNotifier<VoteSubmissionState> {
  final VoteApi _voteApi;

  // CORRECTED: Constructor syntax fixed and does not need to be named.
  VotingController(this._voteApi) : super(const VoteSubmissionState());

  /// Submits the user's vote using the correct API method.
  Future<void> castVote(String ballotId, dynamic selection) async {
    state = state.copyWith(status: VoteSubmissionStatus.loading, clearError: true);

    final result = await _voteApi.castVote(ballotId, selection);

    result.fold(
          (failure) {
        state = state.copyWith(
          status: VoteSubmissionStatus.error,
          errorMessage: failure.message,
        );
      },
          (transactionId) {
        state = state.copyWith(
          status: VoteSubmissionStatus.success,
          transactionId: transactionId,
        );
      },
    );
  }

  /// Resets the controller state to its initial status.
  void reset() {
    state = const VoteSubmissionState(status: VoteSubmissionStatus.initial);
  }
}
