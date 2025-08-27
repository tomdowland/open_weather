import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_weather/extensions/string.dart';
import 'package:open_weather/models/current_weather.dart';

class TodayWeather extends StatelessWidget {
  const TodayWeather({required this.weatherData, super.key});
  final CurrentWeather weatherData;
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MM/dd HH:mm');
    return Column(
      children: [
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
              'https://openweathermap.org/img/wn/${weatherData.weather?[0].icon}@2x.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
        Text(
          date.format(
            DateTime.fromMillisecondsSinceEpoch(
              (weatherData.dt ?? 0) * 1000,
            ),
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          weatherData.weather?[0].description?.toTitleCase ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${weatherData.main?.temp?.toStringAsFixed(0)}°C',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
