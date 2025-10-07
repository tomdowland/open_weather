import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_weather/main.dart';
import 'package:open_weather/ui/pages/settings_page.dart';
import 'package:open_weather/ui/widgets/forecast_list.dart';
import 'package:open_weather/ui/widgets/today_weather.dart';
import 'package:patrol/patrol.dart';

// don't make main async, it breaks the whole thing
void main() {

  patrolTest(
    'app starts up and shows a spinner while it attempts to load weather based on device location',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {

      //required for api calls to work
      await dotenv.load();

      await $.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          child: const MyApp(),
        ),
      );

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionOnlyThisTime();
      }

      expect($(CircularProgressIndicator), findsOneWidget);

      await $.pumpAndSettle();
      expect($(CircularProgressIndicator), findsNothing);

      await $(IconButton).containing(Icons.search).tap();

      await $(TextField).enterText('Paris');
      await $.tester.testTextInput.receiveAction(TextInputAction.done);

      await $.pumpAndSettle();
      expect($(TodayWeather), findsOneWidget);
      expect($(ForecastList), findsOneWidget);

      await $.tap($(IconButton).containing(Icons.settings));
      await $.pumpAndSettle();

      expect($(SettingsPage), findsOneWidget);
    },
  );
}
