import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'location_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Position>()])
void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer createContainer() {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);
    return container;
  }

  const channel = MethodChannel('flutter.baseflow.com/geolocator');

  Future<dynamic> methodHandler(MethodCall call) async {
    if (call.method == 'isLocationServiceEnabled') {
      return true;
    }
    if (call.method == 'checkPermission') {
      //return denied
      return 0;
    }
    if(call.method == 'requestPermission'){
      //return allowed
      return 2;
    }
    if (call.method == 'getCurrentPosition') {
      // requires returned data to be in json
      return Future<Map<String, dynamic>>.value(
        Position(
          longitude: 1,
          latitude: 1,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          altitudeAccuracy: 1,
          heading: 1,
          headingAccuracy: 1,
          speed: 1,
          speedAccuracy: 1,
        ).toJson(),
      );
    }
    return null;
  }

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, methodHandler);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('gps tests', () {
    test('getLocation', () async {
      final container = createContainer();

      await expectLater(
        container.read(locationCheckProvider).getLocation(),
        completion(isA<Position>()),
      );
    });

    test('permission check', () async {
      final container = createContainer();

      await expectLater(
        container.read(locationCheckProvider).checkAndRequestPermission(),
        completion(isA<LocationPermission>()),
      );
    });

    test('location services check', () async {
      final container = createContainer();

      await expectLater(
        container.read(locationCheckProvider).checkLocationServicesEnabled(),
        completion(isA<bool>()),
      );
    });
  });
}
