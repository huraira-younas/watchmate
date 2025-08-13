import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:get_it/get_it.dart';

void setupPlayerLocator() {
  final di = GetIt.instance;
  if (!di.isRegistered<PlayerBloc>()) {
    di.registerLazySingleton(() => PlayerBloc());
  }
}
