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
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecastData.weatherList?.length,
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
                          (item?.dt ?? 0) * 1000,
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
    );
  }
}
