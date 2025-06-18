import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_weather/providers/home_page_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(homePageNotifierProvider);
    DateFormat date = DateFormat('MM/dd HH:mm');
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: weather.editing
            ? TextField(
                autofocus: true,
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
      body: Padding(
        padding: EdgeInsets.only(top: 56),
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: weather.isBusy ? 1 : 0,
              duration: Duration(milliseconds: 100),
              child: Center(child: CircularProgressIndicator()),
            ),
            AnimatedOpacity(
              opacity: weather.isBusy ? 0 : 1,
              duration: Duration(milliseconds: 300),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: weather.weatherResults == null
                        ? Center(child: Text('Sorry, no results found'))
                        : Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 150,
                                  width: 150,
                                  child: Image.network(
                                    'https://openweathermap.org/img/wn/${weather.weatherResults?.icon}@2x.png',
                                  ),
                                ),
                              ),
                              Text(
                                date.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    weather.weatherResults?.dateTime ?? 0,
                                  ),
                                ),
                              ),
                              Text(weather.weatherResults?.weather ?? ''),
                              Text(
                                '${weather.weatherResults?.temperature?.toStringAsFixed(0)}°C',
                              ),

                              SizedBox(height: 50),

                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      weather.weatherResults?.forecast?.length,
                                  itemBuilder: (_, __) {
                                    final item =
                                        weather.weatherResults?.forecast?[__];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      margin: EdgeInsets.all(8),
                                      height: 150,
                                      width: 100,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: Image.network(
                                              'https://openweathermap.org/img/wn/${item?.icon}@2x.png',
                                            ),
                                          ),
                                          Text(item?.weather ?? ''),
                                          Text(
                                            '${item?.temperature.toStringAsFixed(0)}°C',
                                          ),
                                          Text(
                                            date.format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                item!.dateTime,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
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
