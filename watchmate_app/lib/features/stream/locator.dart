import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/features/stream/bloc/upload_bloc/bloc.dart';
import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/features/stream/bloc/link_bloc/bloc.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:get_it/get_it.dart';

void setupStreamLocator() {
  final GetIt di = GetIt.instance;
  if (!di.isRegistered<LinkBloc>()) {
    di.registerLazySingleton(
      () => LinkBloc(
        socket: di<SocketNamespaceService>(),
        authBloc: di<AuthBloc>(),
      ),
    );
  }

  if (!di.isRegistered<UploaderBloc>()) {
    di.registerLazySingleton(() => UploaderBloc(di<VideoRepository>()));
  }
}
