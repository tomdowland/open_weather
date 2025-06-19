import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/providers/async_weather_provider.dart';
import 'package:open_weather/providers/home_page_provider.dart';
import 'package:open_weather/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final weather = ref.watch(homePageNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n!.settings), centerTitle: true),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.all(20) + EdgeInsets.only(top: 16),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(l10n.darkMode, style: TextStyle(fontSize: 24)),
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
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        l10n.languageSettings,
                        style: TextStyle(fontSize: 24),
                      ),
                      // SizedBox(width: 32),
                      Spacer(),
                      Expanded(
                        child: DropdownButtonFormField<Locale>(
                          value: settings.locale,
                          isDense: false,
                          decoration: InputDecoration.collapsed(hintText: ''),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          onChanged: (Locale? newLocale) async {
                            if (newLocale != null) {
                              await ref
                                  .read(settingsNotifierProvider.notifier)
                                  .setLocale(newLocale);
                              await ref
                                  .read(homePageNotifierProvider.notifier)
                                  .searchCity(
                                    weather.weatherResults?.city ?? '',
                                  );
                            }
                          },
                          items: const <DropdownMenuItem<Locale>>[
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Text(
                                'English',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            DropdownMenuItem(
                              value: Locale('ja'),
                              child: Text(
                                '日本語',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
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
