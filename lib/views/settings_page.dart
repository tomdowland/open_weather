import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Settings'), centerTitle: true),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.all(20) + EdgeInsets.only(top: 16),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Dark mode', style: TextStyle(fontSize: 24)),
                      Spacer(),
                      Switch(
                        value: settings.darkMode,
                        onChanged: (_) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .toggleDarkMode();
                        },
                      ),
                    ],
                  ),
                  DropdownButton<Locale>(
                    value: settings.locale,
                    icon: const Icon(Icons.language, color: Colors.white),
                    dropdownColor: Colors.blueGrey[700],
                    underline: const SizedBox(),
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        ref
                            .read(settingsNotifierProvider.notifier)
                            .setLocale(newLocale);
                      }
                    },
                    items: const <DropdownMenuItem<Locale>>[
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(value: Locale('ja'), child: Text('日本語')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
