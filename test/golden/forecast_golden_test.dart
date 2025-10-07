import 'package:alchemist/alchemist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/ui/widgets/forecast_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('forecast widget test', () {
    // final fileConts = File('../.env').readAsStringSync();
    // setUpAll((){dotenv.testLoad(fileInput: fileConts);});

    goldenTest(
      'Forecast',
      fileName: 'forecast',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'Forecast test',
            child: const ProviderScope(
              child: ForecastList(forecastData: ForecastData()),
            ),
          ),
        ],
      ),
    );
  });
}
