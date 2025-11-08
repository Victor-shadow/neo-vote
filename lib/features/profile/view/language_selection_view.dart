import 'package:flutter/material.dart';

class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for languages
    final languages = {
      'en': 'English',
      'sw': 'Kiswahili',
      'rw': 'Kinyarwanda',
    };
    const currentLangCode = 'en'; // This would come from a provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: ListView.separated(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final code = languages.keys.elementAt(index);
          final name = languages.values.elementAt(index);
          return ListTile(
            title: Text(name),
            trailing: code == currentLangCode
                ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              // In a real app, you would call a provider to change the language
              // ref.read(localeProvider.notifier).setLocale(Locale(code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name selected (UI will update).')),
              );
              Navigator.of(context).pop();
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }
}
