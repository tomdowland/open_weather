import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:open_weather/main.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'package:patrol/patrol.dart';

// don't make main async, it breaks the whole thing
void main() {
    patrolTest(
      'app starts up and shows a spinner while it attempts to load weather based on device location',
      framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
      ($) async {
        await $.pumpWidget(
          ProviderScope(
          retry: (retryCount, error) => null,
            child: const MyApp(),
          ),
        );
        // final container = $.tester.container();

        if (await $.native.isPermissionDialogVisible()) {
          await $.native.grantPermissionOnlyThisTime();
        }

        expect($(CircularProgressIndicator), findsOneWidget);

        await $.pumpAndSettle();
// print(container.read(asyncWeatherProvider).error);
        expect($(CircularProgressIndicator), findsNothing);

        await $(IconButton).containing(Icons.search).tap();

        await $(TextField).enterText('Paris');
        await $.tester.testTextInput.receiveAction(TextInputAction.done);

        await $.pumpAndSettle();

        // expect($(TodayWeather), findsOneWidget);
        // expect($(ForecastList), findsOneWidget);
        //
        // await $.tap($(IconButton).containing(Icons.settings));
        // await $.pumpAndSettle();
        //
        // expect($(SettingsPage), findsOneWidget);
      },
    );
}
