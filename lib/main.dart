import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/meta/theme.dart';
import 'package:open_weather/providers/settings_provider.dart';
import 'package:open_weather/views/home_page.dart';
import 'package:open_weather/views/settings_page.dart';

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'settings',
          builder: (context, state) {
            return const SettingsPage();
          },
        ),
      ],
    ),
  ],
);

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    return MaterialApp.router(
      routerConfig: _router,
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: settings.locale,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      supportedLocales: [Locale('en'), Locale('ja')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
