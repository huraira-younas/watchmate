import 'package:watchmate_app/features/stream/locator.dart';
import 'package:watchmate_app/features/auth/locator.dart';
import 'package:watchmate_app/common/locator.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  setupCommonLocator();
  setupAuthLocator();

  // STREAM: Depends on Socket and Auth Locator
  setupStreamLocator();
}
