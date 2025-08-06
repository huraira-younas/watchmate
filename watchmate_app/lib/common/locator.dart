import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/cubits/theme_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt di = GetIt.instance;

void setupCommonLocator() {
  if (!di.isRegistered<VideoRepository>()) {
    di.registerLazySingleton(() => VideoRepository());
  }

  if (!di.isRegistered<ThemeCubit>()) {
    di.registerLazySingleton(() => ThemeCubit());
  }
}
