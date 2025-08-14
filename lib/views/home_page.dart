import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_weather/extensions/string.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:open_weather/providers/home_page_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(homePageNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final date = DateFormat('MM/dd HH:mm');
    final searchController = useTextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: weather.editing
            ? TextField(
                autofocus: true,
                controller: searchController,
                decoration: InputDecoration(hintText: l10n!.enterCityHint),
                onSubmitted: ref
                    .read(homePageNotifierProvider.notifier)
                    .searchCity,
              )
            : Text(
                weather.weatherResults?.city?.name ??
                    (searchController.text.isNotEmpty
                        ? searchController.text
                        : l10n!.weatherAppTitle),
                textAlign: TextAlign.center,
              ),
        centerTitle: true,
        actions: [
          if (weather.editing)
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
            icon: Icon(weather.editing ? Icons.cancel : Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 56),
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: weather.isBusy && !weather.hasError ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: const Center(child: CircularProgressIndicator()),
            ),
            AnimatedOpacity(
              opacity: weather.isBusy && !weather.hasError ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: weather.hasError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            switch (weather.errorType) {
                              RequestError.requestTimeout => Text(
                                l10n!.timeout,
                                // l10n!.networkError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24),
                              ),
                              RequestError.locationPermissionsDenied => Text(
                                l10n!.locationPermissionsDenied,
                                // l10n!.networkError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24),
                              ),
                              RequestError
                                  .locationPermissionsPermanentlyDenied =>
                                Text(
                                  l10n!.locationPermissionsPermanentlyDenied,
                                  // l10n!.networkError,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              RequestError.locationServicesDisabled => Text(
                                l10n!.locationServicesDisabled,
                                // l10n!.networkError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24),
                              ),
                              RequestError.networkError => Text(
                                l10n!.networkError,
                                // l10n!.networkError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24),
                              ),
                              RequestError.notFound => Text(
                                l10n!.noResults,
                                // l10n!.networkError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24),
                              ),
                              _ => const Text(''),
                            },

                            const SizedBox(
                              height: 50,
                            ),
                            TextButton(
                              child: const Text(
                                'Retry',
                              ), //TODO customise button
                              onPressed: () => ref
                                  .read(homePageNotifierProvider.notifier)
                                  .searchCity(searchController.text),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: weather.weatherResults == null
                              ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  switch (weather.errorType) {
                                    RequestError.requestTimeout => Text(
                                      l10n!.timeout,
                                      // l10n!.networkError,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    RequestError.locationPermissionsDenied => Text(
                                      l10n!.locationPermissionsDenied,
                                      // l10n!.networkError,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    RequestError
                                        .locationPermissionsPermanentlyDenied =>
                                        Text(
                                          l10n!.locationPermissionsPermanentlyDenied,
                                          // l10n!.networkError,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                    RequestError.locationServicesDisabled => Text(
                                      l10n!.locationServicesDisabled,
                                      // l10n!.networkError,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    RequestError.networkError => Text(
                                      l10n!.networkError,
                                      // l10n!.networkError,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    RequestError.notFound => Text(
                                      l10n!.noResults,
                                      // l10n!.networkError,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    _ => const Text(''),
                                  },

                                  const SizedBox(
                                    height: 50,
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Retry',
                                    ), //TODO customise button
                                    onPressed: () => ref
                                        .read(homePageNotifierProvider.notifier)
                                        .searchCity(searchController.text),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : Column(
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
                                        child: Image.network(
                                          'https://openweathermap.org/img/wn/${weather.currentWeather?.weather?[0].icon}@2x.png',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      date.format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          weather.currentWeather!.dt! * 1000,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      weather
                                              .currentWeather
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
                                      '${weather.currentWeather?.main?.temp?.toStringAsFixed(0)}°C',
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
                                        itemCount: weather
                                            .weatherResults
                                            ?.weatherList
                                            ?.length,
                                        itemBuilder: (_, __) {
                                          final item = weather
                                              .weatherResults
                                              ?.weatherList?[__];
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                              borderRadius:
                                                  const BorderRadius.all(
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
                                                  child: Image.network(
                                                    'https://openweathermap.org/img/wn/${item?.weather?[0].icon}@2x.png',
                                                  ),
                                                ),
                                                Text(
                                                  date.format(
                                                    DateTime.fromMillisecondsSinceEpoch(
                                                      item!.dt! * 1000,
                                                    ),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  item
                                                          .weather?[0]
                                                          .description
                                                          ?.toTitleCase ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  '${item.main?.temp?.toStringAsFixed(0)}°C',
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
