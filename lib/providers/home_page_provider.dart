import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_page_provider.freezed.dart';
part 'home_page_provider.g.dart';

@freezed
abstract class FrontPage with _$FrontPage {
  factory FrontPage({
    @Default(false) bool editing,
  }) = _FrontPage;
}

@riverpod
class HomePageNotifier extends _$HomePageNotifier {
  @override
  FrontPage build() {
    return FrontPage();
  }

  void editCity() {
    state = state.copyWith(editing: !state.editing);
  }
}
