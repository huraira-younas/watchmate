import 'repository/repository.dart';
import 'package:get_it/get_it.dart';
import 'bloc/bloc.dart';

final GetIt diAuth = GetIt.instance;

void setupAuthLocator() {
  if (!diAuth.isRegistered<AuthRepository>()) {
    diAuth.registerLazySingleton(() => AuthRepository());
  }

  if (!diAuth.isRegistered<AuthBloc>()) {
    diAuth.registerLazySingleton(() => AuthBloc(diAuth<AuthRepository>()));
  }
}
