import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/ui/widgets/today_weather.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // final fileConts = File('../.env').readAsStringSync();
  // setUpAll((){
  //   dotenv.testLoad(fileInput: fileConts);
  // });
  group('Home Page golden tests', () {
    goldenTest(
      'Today Weatehr',
      fileName: 'todayWeather',
      builder: () {

        return GoldenTestGroup(
          children: [
            GoldenTestScenario(
              name: 'Today',
              child: const ProviderScope(
                child: TodayWeather(weatherData: CurrentWeather()),
              ),
            ),
          ],
        );
      },
    );
  });
}
