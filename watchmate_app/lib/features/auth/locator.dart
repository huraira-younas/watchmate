import 'repository/repository.dart';
import 'package:get_it/get_it.dart';
import 'bloc/bloc.dart';

void setupAuthLocator() {
  final GetIt di = GetIt.instance;
  if (!di.isRegistered<AuthRepository>()) {
    di.registerLazySingleton(() => AuthRepository());
  }

  if (!di.isRegistered<AuthBloc>()) {
    di.registerLazySingleton(() => AuthBloc(di<AuthRepository>()));
  }
}
