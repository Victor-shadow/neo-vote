// lib/features/profile/widgets/profile_container.dart

import 'package:flutter/material.dart';

/// A reusable container widget for styling sections on the profile screen.
///
/// This widget provides a consistent look with rounded corners, a subtle
/// border, and clipping to ensure its child's corners are also rounded.
class ProfileContainer extends StatelessWidget {
  final Widget child;

  const ProfileContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12.0),
      ),
      // ClipRRect ensures the child (e.g., a ListTile) respects the border radius.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.0), // Slightly smaller radius
        child: child,
      ),
    );
  }
}
