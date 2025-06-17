import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(color: Colors.green, height: 100, width: 100),
                Row(
                  children: [
                    Text('Dark mode'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
