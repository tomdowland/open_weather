import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_weather/providers/location_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  ProviderContainer createContainer() {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);
    return container;
  }

  group('description', () {
    test('description', () async {
      final container = createContainer();

      await expectLater(
        container.read(locationCheckProvider).checkLocationServicesEnabled(),
        completion(isA<bool>()),
      );
    });
  });
}
