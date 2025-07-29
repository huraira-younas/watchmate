import 'package:watchmate_app/features/auth/locator.dart';
import 'package:watchmate_app/common/cubits/theme_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => ThemeCubit());
  setupAuthLocator();
}
