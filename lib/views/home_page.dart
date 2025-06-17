import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_weather/providers/home_page_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(homePageNotifierProvider);
    if (weather.isBusy ?? true) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: weather.editing
            ? TextField(
                onSubmitted: ref
                    .read(homePageNotifierProvider.notifier)
                    .searchCity,
              )
            : Text(
                weather.weatherResults?.city ?? '',
                textAlign: TextAlign.center,
              ),
        centerTitle: true,
        actions: [
          weather.editing
              ? SizedBox()
              : IconButton(
                  onPressed: () {
                    context.go('/settings');
                    // move to settings page
                  },
                  icon: Icon(Icons.settings),
                ),
          IconButton(
            onPressed: () {
              ref.read(homePageNotifierProvider.notifier).editCity();
            },
            icon: Icon(weather.editing ? Icons.cancel : Icons.search),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: weather.weatherResults == null
                ? Center(child: Text('Sorry, no results found'))
                : Column(
                    children: [
                      ColoredBox(
                        color: Colors.red,
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Image.network(
                            'https://openweathermap.org/img/wn/${weather.weatherResults?.icon}@2x.png',
                          ),
                        ),
                      ),
                      Text(
                        '${DateTime.fromMillisecondsSinceEpoch(weather.weatherResults?.dateTime ?? 0)}',
                      ),
                      Text(weather.weatherResults?.weather ?? ''),
                      Text(
                        weather.weatherResults?.temperature.toString() ?? '',
                      ),

                      Container(height: 50, width: 50, color: Colors.purple),

                      // SingleChildScrollView(
                      // scrollDirection: Axis.horizontal,
                      // child:
                      Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: weather.weatherResults?.forecast?.length,
                          itemBuilder: (_, __) {
                            final item = weather.weatherResults?.forecast?[__];
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
