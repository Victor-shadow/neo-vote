// TODO Implement this library.
// lib/features/receipts/widgets/receipt_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neo_vote/core/models/receipt_model.dart';
import 'package:neo_vote/features/receipts/view/receipt_detail_view.dart';

/// A widget that displays a summary of a single vote receipt in a list.
///
/// It shows the election title and the date the vote was cast. Tapping on
/// the item navigates the user to the `ReceiptDetailView` for more information.
class ReceiptListItem extends StatelessWidget {
  final Receipt receipt;

  const ReceiptListItem({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(
          Icons.receipt_long_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          receipt.electionTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Voted on: ${DateFormat.yMMMd().format(receipt.dateCasted)}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to the detail view, passing the transaction ID.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReceiptDetailView(
                transactionId: receipt.transactionId,
              ),
            ),
          );
        },
      ),
    );
  }
}
