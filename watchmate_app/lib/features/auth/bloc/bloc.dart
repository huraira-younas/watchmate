import 'package:watchmate_app/features/auth/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'events.dart';
import 'states.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;
  UserModel? user;

  AuthBloc(this.repo) : super(AuthState()) {
    on<AuthRegister>(_onRegister);
    on<AuthLogout>(_onLogout);
    on<AuthLogin>(_onLogin);
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    final loading = CustomState(message: "Please wait...", title: "Login");
    _emit(loading: loading, emit);

    try {
      user = await repo.login(event.toJson());
      _emit(emit);
    } catch (e) {
      final error = CustomState(message: e.toString(), title: "Login Error");
      _emit(error: error, emit);
    }
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    final loading = CustomState(message: "Please wait...", title: "Register");
    _emit(loading: loading, emit);

    try {
      user = await repo.register(event.toJson());
      _emit(emit);
    } catch (e) {
      final error = CustomState(message: e.toString(), title: "Register Error");
      _emit(error: error, emit);
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await repo.logout();
    user = null;
    _emit(emit);
  }

  void _emit(Emitter emit, {CustomState? loading, CustomState? error}) =>
      emit(AuthState(error: error, loading: loading, user: user));
}
