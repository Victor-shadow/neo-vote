// lib/features/profile/widgets/theme_switcher_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_vote/presentation/theme/theme_provider.dart';

class ThemeSwitcherWidget extends ConsumerWidget {
  const ThemeSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CORRECTED: Use the generated 'themeNotifierProvider'.
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Switch(
      value: isDarkMode,
      onChanged: (isOn) {
        final newTheme = isOn ? ThemeMode.dark : ThemeMode.light;
        // CORRECTED: Read the notifier to call its methods.
        ref.read(themeNotifierProvider.notifier).setTheme(newTheme);
      },
      activeTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      activeThumbColor: Theme.of(context).colorScheme.primary,
    );
  }
}
