import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_weather/views/home_page.dart';
import 'package:open_weather/views/search_page.dart';
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
          path: 'search',
          builder: (context, state) {
            return const SearchPage();
          },
        ),
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
    return MaterialApp.router(routerConfig: _router);
  }
}
