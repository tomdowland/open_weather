import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_weather/extensions/error_type.dart';
import 'package:open_weather/extensions/string.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/providers/error_provider.dart';
import 'package:open_weather/providers/home_page_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(homePageNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final date = DateFormat('MM/dd HH:mm');
    final searchController = useTextEditingController();
    final asyncWeather = ref.watch(asyncWeatherProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: pageState.editing
            ? TextField(
                autofocus: true,
                controller: searchController,
                decoration: InputDecoration(hintText: l10n!.enterCityHint),
                onSubmitted: (city) async {
                  await ref
                      .read(asyncWeatherProvider.notifier)
                      .searchWeather(city);

                  ref.read(homePageNotifierProvider.notifier).editCity();
                },
              )
            : Text(
                asyncWeather.value?.currentWeatherData?.name ??
                    (searchController.text.isNotEmpty
                        ? searchController.text
                        : l10n!.weatherAppTitle),
                textAlign: TextAlign.center,
              ),
        centerTitle: true,
        actions: [
          if (pageState.editing)
            const SizedBox()
          else
            IconButton(
              onPressed: () {
                context.go('/settings');
                // move to settings page
              },
              icon: const Icon(Icons.settings),
            ),
          IconButton(
            onPressed: () {
              searchController.clear();
              ref.read(homePageNotifierProvider.notifier).editCity();
            },
            icon: Icon(pageState.editing ? Icons.cancel : Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 56),
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: asyncWeather.isLoading && !asyncWeather.hasError ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: const Center(child: CircularProgressIndicator()),
            ),
            AnimatedOpacity(
              opacity: asyncWeather.isLoading && !asyncWeather.hasError ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: asyncWeather.hasError
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ref
                                    .watch(
                                      errorHandlerProvider(
                                        (asyncWeather.error ?? Exception())
                                            as Exception,
                                      ),
                                    )
                                    ?.localisedMessage(context) ??
                                '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24),
                          ),
                          if (searchController.text.isNotEmpty)
                            TextButton(
                              child: Text(
                                l10n!.retry,
                              ), // TODOcustomise button
                              onPressed: () async {
                                await ref
                                    .read(
                                      asyncWeatherProvider.notifier,
                                    )
                                    .searchWeather(
                                      searchController.text,
                                    );
                              },
                            ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            children: [
                              Text(
                                l10n!.currentWeather,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 150,
                                  width: 150,
                                  child: asyncWeather.isLoading
                                      ? const SizedBox()
                                      : Image.network(
                                          'https://openweathermap.org/img/wn/${asyncWeather.value?.currentWeatherData?.weather?[0].icon}@2x.png',
                                          loadingBuilder: (_, child, chunk) {
                                            if (chunk?.cumulativeBytesLoaded !=
                                                chunk?.expectedTotalBytes) {
                                              return const CircularProgressIndicator();
                                            } else {
                                              return child;
                                            }
                                          },
                                        ),
                                ),
                              ),
                              Text(
                                date.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    (asyncWeather
                                                .value
                                                ?.currentWeatherData
                                                ?.dt ??
                                            0) *
                                        1000,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                asyncWeather
                                        .value
                                        ?.currentWeatherData
                                        ?.weather?[0]
                                        .description
                                        ?.toTitleCase ??
                                    '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${asyncWeather.value?.currentWeatherData?.main?.temp?.toStringAsFixed(0)}°C',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 50),
                              Text(
                                l10n.weatherForecast,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: asyncWeather
                                      .value
                                      ?.forecastData
                                      ?.weatherList
                                      ?.length,
                                  itemBuilder: (_, __) {
                                    final item = asyncWeather
                                        .value
                                        ?.forecastData
                                        ?.weatherList?[__];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).cardColor,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      margin: const EdgeInsets.all(8),
                                      height: 160,
                                      width: 120,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: asyncWeather.isLoading
                                                ? const SizedBox()
                                                : Image.network(
                                                    'https://openweathermap.org/img/wn/${item?.weather?[0].icon}@2x.png',
                                                  ),
                                          ),
                                          Text(
                                            date.format(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                (item?.dt ?? 0) * 1000,
                                              ),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            item
                                                    ?.weather?[0]
                                                    .description
                                                    ?.toTitleCase ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            '${item?.main?.temp?.toStringAsFixed(0)}°C',
                                            style: const TextStyle(
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
