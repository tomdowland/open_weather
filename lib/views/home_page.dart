import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_weather/providers/weather_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(weather.value?.city ?? '', textAlign: TextAlign.center),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.go('/settings');
              // move to settings page
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              context.go('/search');
              // ref.read(weatherProvider.notifier).fetchWeather('Tokyo');
              // move to settings page
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                ColoredBox(
                  color: Colors.red,
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.network(
                      'https://openweathermap.org/img/wn/${weather.value?.icon}@2x.png',
                    ),
                  ),
                ),
                Text(
                  '${DateTime.fromMillisecondsSinceEpoch(weather.value?.dateTime ?? 0)}',
                ),
                Text(weather.value?.weather ?? ''),
                Text(weather.value?.temperature.toString() ?? ''),

                Container(height: 50, width: 50, color: Colors.purple),

                // SingleChildScrollView(
                // scrollDirection: Axis.horizontal,
                // child:
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weather.value?.forecast?.length,
                    itemBuilder: (_, __) {
                      final item = weather.value?.forecast?[__];
                      return Container(
                        margin: EdgeInsets.all(8),
                        height: 100,
                        width: 100,
                        color: Colors.orange,
                        child: Column(
                          children: [
                            Text(item?.weather ?? 'hello'),
                            Text(item?.temperature.toString() ?? ''),
                            Text(
                              '${DateTime.fromMillisecondsSinceEpoch(item!.dateTime)}',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
