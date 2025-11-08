// lib/features/receipts/view/receipt_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neo_vote/api/vote_api.dart';
import 'package:neo_vote/core/models/receipt_model.dart';
import 'package:neo_vote/core/services/secure_storage_service.dart';
import 'package:neo_vote/presentation/common_widgets/error_display_widget.dart';
import 'package:neo_vote/presentation/common_widgets/loading_spinner.dart';
import 'package:http/http.dart' as http;

// --- Providers for this View ---

// CORRECTED: A simple provider that creates and returns an http.Client instance.
final httpClientProvider = Provider((ref) => http.Client());

// This provider should likely be defined in a more central location if used elsewhere.
final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

// Provider for the VoteApi, correctly constructed with its dependencies.
final _voteApiProvider = Provider((ref) => VoteApi(
      // CORRECTED: Watch the new httpClientProvider.
      client: ref.watch(httpClientProvider),
      storageService: ref.watch(secureStorageServiceProvider),
    ));

/// Provider to fetch all receipts for the current user.
final receiptsProvider = FutureProvider.autoDispose<List<Receipt>>((ref) async {
  final voteApi = ref.watch(_voteApiProvider);
  final result = await voteApi.getVoteReceipts();
  return result.fold(
    (failure) => throw failure.message,
    (receipts) => receipts,
  );
});

/// Provider to find a single receipt by its transaction ID from the full list.
/// This is more efficient than a separate API call if the list is already fetched.
final receiptByIdProvider =
    Provider.autoDispose.family<Receipt?, String>((ref, transactionId) {
  final receiptsAsync = ref.watch(receiptsProvider);
  return receiptsAsync.whenData((receipts) {
    try {
      return receipts.firstWhere((r) => r.transactionId == transactionId);
    } catch (e) {
      return null; // Return null if not found
    }
  }).value;
});

// --- View ---

/// A view that displays the detailed information of a single vote receipt.
class ReceiptDetailView extends ConsumerWidget {
  final String transactionId;

  const ReceiptDetailView({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that finds a single receipt by its ID.
    final receipt = ref.watch(receiptByIdProvider(transactionId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote Receipt Details'),
      ),
      body: Builder(
        builder: (context) {
          // Handle loading and error states from the source provider
          final receiptsAsync = ref.watch(receiptsProvider);
          return receiptsAsync.when(
            data: (receipts) {
              if (receipt == null) {
                return const ErrorDisplayWidget(
                    errorMessage: 'Receipt not found.');
              }
              return _buildReceiptDetails(context, theme, receipt);
            },
            loading: () => const LoadingSpinner(),
            error: (err, stack) =>
                ErrorDisplayWidget(errorMessage: err.toString()),
          );
        },
      ),
    );
  }

  Widget _buildReceiptDetails(
      BuildContext context, ThemeData theme, Receipt receipt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context: context,
            theme: theme,
            title: 'Election',
            content: receipt.electionTitle,
            icon: Icons.poll_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            theme: theme,
            title: 'Date Voted',
            content: DateFormat.yMMMd().add_jm().format(receipt.dateCasted),
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            theme: theme,
            title: 'Blockchain Transaction ID',
            content: receipt.transactionId,
            icon: Icons.receipt_long_outlined,
            isCopyable: true,
          ),
          const SizedBox(height: 24),
          Text(
            'This receipt confirms that your vote was securely and anonymously recorded on the blockchain.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String content,
    required IconData icon,
    bool isCopyable = false,
  }) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    content,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isCopyable)
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Transaction ID copied to clipboard!')),
                      );
                    },
                    tooltip: 'Copy ID',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
