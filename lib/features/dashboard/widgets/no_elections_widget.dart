import 'package:flutter/material.dart';

class NoElectionsWidget extends StatelessWidget {
  const NoElectionsWidget({super.key});

  @override
  Widget build(BuildContext context){
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(32.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 24),
                Text(
                  'No Active Elections',
                  style: Theme.of(context)
                  .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'There are currently no active elections for you to vote in. Pull down to refresh or check back later',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
          ),
          ),
        )
        ),
      );
    });
  }
}