import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/features/my_list/bloc/bloc.dart';
import 'package:get_it/get_it.dart';

void setupListLocator() {
  final di = GetIt.instance;
  if (!di.isRegistered<ListBloc>()) {
    di.registerLazySingleton(() => ListBloc(di<VideoRepository>()));
  }
}
