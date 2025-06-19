import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_weather/extensions/string.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/providers/home_page_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(homePageNotifierProvider);
    final l10n = AppLocalizations.of(context);
    DateFormat date = DateFormat('MM/dd HH:mm');
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: weather.editing
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: l10n!.enterCityHint),
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
              opacity: weather.isBusy && !weather.networkError ? 1 : 0,
              duration: Duration(milliseconds: 100),
              child: Center(child: CircularProgressIndicator()),
            ),
            AnimatedOpacity(
              opacity: weather.isBusy && !weather.networkError ? 0 : 1,
              duration: Duration(milliseconds: 300),
              child: weather.networkError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n!.networkError,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: weather.weatherResults == null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      l10n!.noResults,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Text(
                                      l10n!.currentWeather,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      weather
                                              .weatherResults
                                              ?.weather
                                              ?.toTitleCase ??
                                          '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${weather.weatherResults?.temperature?.toStringAsFixed(0)}°C',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    SizedBox(height: 50),
                                    Text(
                                      l10n.weatherForecast,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    SizedBox(
                                      height: 150,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: weather
                                            .weatherResults
                                            ?.forecast
                                            ?.length,
                                        itemBuilder: (_, __) {
                                          final item = weather
                                              .weatherResults
                                              ?.forecast?[__];
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                            ),
                                            margin: EdgeInsets.all(8),
                                            height: 160,
                                            width: 120,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child: Image.network(
                                                    'https://openweathermap.org/img/wn/${item?.icon}@2x.png',
                                                  ),
                                                ),
                                                Text(
                                                  date.format(
                                                    DateTime.fromMillisecondsSinceEpoch(
                                                      item?.dateTime ?? 0,
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  item?.weather.toTitleCase ??
                                                      '',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  '${item?.temperature.toStringAsFixed(0)}°C',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
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
