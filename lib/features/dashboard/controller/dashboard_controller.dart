import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/core/models/election_model.dart';
import 'package:neo_vote/core/providers/api_providers.dart';

// This provider fetches the list of active elections
final electionsProvider = FutureProvider<List<Election>>((ref) async {
  final electionApi = ref.watch(electionApiProvider);

  //Call the API method
  final result = await electionApi.getActiveElections();

  return result.fold(
    (failure) => throw failure,
    (elections) => elections,
  );
});
