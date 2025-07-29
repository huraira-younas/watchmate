import 'package:watchmate_app/features/auth/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'events.dart';
import 'states.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;
  UserModel? user;

  AuthBloc(this.repo) : super(AuthState()) {
    on<AuthLogout>(_onLogout);
    on<AuthLogin>(_onLogin);
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    _emit(emit, loading: true);
    try {
      user = await repo.login(event.email, event.password);
      _emit(emit, loading: false);
    } catch (e) {
      _emit(emit, loading: false, error: e.toString());
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await repo.logout();
    user = null;
    _emit(emit);
  }

  void _emit(Emitter emit, {bool loading = false, String? error}) => emit(
    AuthState(error: error ?? state.error, loading: loading, user: user),
  );
}
