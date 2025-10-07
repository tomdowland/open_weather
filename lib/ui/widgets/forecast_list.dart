import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_weather/extensions/string.dart';
import 'package:open_weather/models/forecast_data.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({required this.forecastData, super.key});
  final ForecastData forecastData;
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MM/dd HH:mm');
    return Column(
      children: [
        SizedBox(
          height: 176,
          width: MediaQuery.maybeWidthOf(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecastData.weatherList?.length ?? 40,
            itemBuilder: (_, __) {
              final item = forecastData.weatherList?[__];
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
                width: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: item?.weather?[0].icon!=null?Image.network(
                        'https://openweathermap.org/img/wn/${item?.weather?[0].icon}@2x.png',
                        errorBuilder: (context, exception, stackTrace) =>
                            const SizedBox(),
                      ):const SizedBox(),
                    ),
                    Text(
                      date.format(
                        DateTime.fromMillisecondsSinceEpoch(
                          (item?.dt??0 + (forecastData.city?.timezone??0)) *
                              1000,
                          isUtc: true,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      item?.weather?[0].description?.toTitleCase ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${(item?.main?.temp??0).toStringAsFixed(0)}°C',
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
    );
  }
}
