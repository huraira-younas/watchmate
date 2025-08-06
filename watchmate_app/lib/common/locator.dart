import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/cubits/navigation_cubit.dart';
import 'package:watchmate_app/common/cubits/theme_cubit.dart';
import 'package:watchmate_app/common/cubits/video_cubit.dart';
import 'package:get_it/get_it.dart';

void setupCommonLocator() {
  final di = GetIt.instance;

  if (!di.isRegistered<VideoRepository>()) {
    di.registerLazySingleton(() => VideoRepository());
  }

  if (!di.isRegistered<VideoCubit>()) {
    di.registerLazySingleton(() => VideoCubit(di<VideoRepository>()));
  }

  if (!di.isRegistered<ThemeCubit>()) {
    di.registerLazySingleton(() => ThemeCubit());
  }

  if (!di.isRegistered<SocketNamespaceService>()) {
    di.registerLazySingleton(() => SocketNamespaceService());
  }

  if (!di.isRegistered<NavigationCubit>()) {
    di.registerLazySingleton(() => NavigationCubit());
  }
}
