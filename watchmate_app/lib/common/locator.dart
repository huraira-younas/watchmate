import 'services/socket_service/socket_service.dart';
import 'package:watchmate_app/database/db.dart';
import 'repositories/video_repository.dart';
import 'blocs/transfer_bloc/bloc.dart';
import 'cubits/navigation_cubit.dart';
import 'package:get_it/get_it.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/video_cubit.dart';

void setupCommonLocator() {
  final di = GetIt.instance;

  if (!di.isRegistered<AppDatabase>()) {
    di.registerLazySingleton(() => AppDatabase());
  }

  if (!di.isRegistered<VideoRepository>()) {
    di.registerLazySingleton(() => VideoRepository());
  }

  if (!di.isRegistered<TransferBloc>()) {
    di.registerLazySingleton(
      () => TransferBloc(di<VideoRepository>(), di<AppDatabase>()),
    );
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
