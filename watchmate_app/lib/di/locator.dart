import 'package:watchmate_app/services/socket_service/socket_service.dart';
import 'package:watchmate_app/features/auth/locator.dart';
import 'package:watchmate_app/common/locator.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => SocketNamespaceService());
  setupCommonLocator();
  setupAuthLocator();
}
