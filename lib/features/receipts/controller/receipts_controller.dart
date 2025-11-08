// lib/features/receipts/controller/receipts_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/core/models/receipt_model.dart';
import 'package:neo_vote/features/voting/controller/voting_controller.dart'; // Re-using providers

/// Provider that fetches the list of vote receipts for the authenticated user.
///
/// It automatically handles loading and error states and will be re-fetched
/// if the underlying API provider changes or if it's manually invalidated.
final receiptsProvider = FutureProvider.autoDispose<List<Receipt>>((ref) async {
  // Depend on the voteApiProvider, which is already defined and configured.
  final voteApi = ref.watch(voteApiProvider);

  // Call the API to get the receipts.
  final result = await voteApi.getVoteReceipts();

  // Handle the Either result: throw an error on failure, or return data on success.
  // The FutureProvider will automatically catch the error and expose it.
  return result.fold(
    (failure) => throw failure.message,
    (receipts) {
      // Sort receipts by date, from newest to oldest.
      receipts.sort((a, b) => b.dateCasted.compareTo(a.dateCasted));
      return receipts;
    },
  );
});
