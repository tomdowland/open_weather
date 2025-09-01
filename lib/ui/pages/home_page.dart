import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_weather/extensions/error_type.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/providers/error_provider.dart';
import 'package:open_weather/providers/home_page_provider.dart';
import 'package:open_weather/ui/widgets/forecast_list.dart';
import 'package:open_weather/ui/widgets/today_weather.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(homePageNotifierProvider);
    final l10n = AppLocalizations.of(context);
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
                  ref.read(homePageNotifierProvider.notifier).editCity();
                  await ref
                      .read(asyncWeatherProvider.notifier)
                      .updateWeather(city);
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
            onPressed: asyncWeather.isLoading?null:() {
              searchController.clear();
              ref.read(homePageNotifierProvider.notifier).editCity();
            },
            icon: Icon(pageState.editing ? Icons.cancel : Icons.search),
          ),
        ],
        leading: IconButton(
          onPressed: asyncWeather.isLoading
              ? null
              : ()async {
            if(pageState.editing) {
                    ref.read(homePageNotifierProvider.notifier).editCity();
                  }
                  await ref
                .read(asyncWeatherProvider.notifier)
                .getNewLocationWeather();
          },
          icon: const Icon(Icons.gps_fixed),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 100),
        child: asyncWeather.when(
          data: (data) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Text(
                          l10n!.currentWeather,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TodayWeather(
                          weatherData: data!.currentWeatherData!,
                        ),

                        const SizedBox(height: 50),
                        Text(
                          l10n.weatherForecast,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        ForecastList(
                          forecastData: data.forecastData!,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            final errorHandler = ref.watch(
              errorHandlerProvider(error),
            );
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorHandler?.localisedMessage(context) ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24),
                  ),
                  TextButton(
                    onPressed: () => ref.refresh(asyncWeatherProvider),
                    child: Text(l10n!.retry),
                  ),
                ],
              ),
            );
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
