import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/features/stream/bloc/bloc.dart';
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
}
