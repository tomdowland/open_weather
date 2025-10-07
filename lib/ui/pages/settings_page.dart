import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/providers/locale_provider.dart';
import 'package:open_weather/providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeSettingProvider);
    final themeMode = ref.watch(themeSettingProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n!.settings), centerTitle: true),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: const EdgeInsets.all(20) + const EdgeInsets.only(top: 16),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(l10n.darkMode, style: const TextStyle(fontSize: 24)),
                      const Spacer(),
                      Switch(
                        value: themeMode.darkMode,
                        onChanged: (_) {
                          ref
                              .read(themeSettingProvider.notifier)
                              .toggleDarkMode();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        l10n.languageSettings,
                        style: const TextStyle(fontSize: 24),
                      ),
                      // SizedBox(width: 32),
                      const Spacer(),
                      Expanded(
                        child: DropdownButtonFormField<Locale>(
                          initialValue: locale.locale,
                          isDense: false,
                          decoration: const InputDecoration.collapsed(
                            hintText: '',
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          onChanged: (Locale? newLocale) async {
                            if (newLocale != null &&
                                newLocale != locale.locale) {
                              await ref
                                  .read(localeSettingProvider.notifier)
                                  .setLocale(newLocale);
                            }
                          },
                          items: <DropdownMenuItem<Locale>>[
                            DropdownMenuItem(
                              value: const Locale('en'),
                              child: Text(
                                l10n.english,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            DropdownMenuItem(
                              value: const Locale('ja'),
                              child: Text(
                                l10n.japanese,
                                style: const TextStyle(fontSize: 20),
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
