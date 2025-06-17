import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_weather/providers/weather_provider.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherNotifierProvider);
    TextEditingController citySearch = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                TextField(
                  controller: citySearch,
                  onSubmitted: (input) async {
                    await ref
                        .read(weatherNotifierProvider.notifier)
                        .fetchWeatherByCity(input)
                        .whenComplete(() => context.pop());
                  },
                ),
                Container(color: Colors.blue, height: 100, width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
