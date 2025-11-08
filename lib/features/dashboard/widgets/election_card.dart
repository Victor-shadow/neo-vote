import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neo_vote/core/models/election_model.dart';

class ElectionCard extends StatelessWidget {
  final Election election;

  const ElectionCard({super.key, required this.election});

  // Helper to format duration in a readable way
  String _formatDuration(Duration d){
    if (d.isNegative) return "Closed";
    if (d.inDays > 1) return '${d.inDays} days';
    if (d.inDays == 1) return '1 Day';
    if (d.inHours > 0) return '${d.inHours} hours';
    if (d.inMinutes > 0) return '${d.inMinutes} minutes';
    return 'Less than a minute';
  }

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context);
    final timeRemaining = election.endTime.difference(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
       onTap: (){
          //Navigate to the voting screen
         Navigator.of(context).pushNamed('/voting', arguments: election.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                election.title,
                style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                theme,
                icon: Icons.timer_outlined,
                label: 'Closes In',
                value: _formatDuration(timeRemaining),
                valueColor: timeRemaining.inHours < 24 ?  Colors.orange.shade800 : null,
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                theme,
                icon: Icons.calendar_today_outlined,
                label: 'End Date',
                value: DateFormat.yMMMd().add_jm().format(election.endTime),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap to Vote',
                      style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ),
    );
  }

  Widget _buildInfoRow(ThemeData theme,
  {required IconData icon,
  required String label,
  required String value,
  Color? valueColor}){
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}