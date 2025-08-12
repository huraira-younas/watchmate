import 'package:watchmate_app/features/auth/repository/repository.dart';
import 'package:watchmate_app/common/models/custom_state_model.dart';
import 'package:watchmate_app/features/auth/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'event.dart';
part 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;
  UserModel? user;

  AuthBloc(this.repo) : super(AuthState()) {
    on<AuthUpdatePassword>(_onUpdatePassword);
    on<AuthUpdateUser>(_onAuthUpdateUser);
    on<AuthVerifyCode>(_onVerifyCode);
    on<AuthRegister>(_onRegister);
    on<AuthGetUser>(_onGetUser);
    on<AuthGetCode>(_onGetCode);
    on<AuthLogout>(_onLogout);
    on<AuthLogin>(_onLogin);
  }

  Future<void> _onAuthUpdateUser(
    AuthUpdateUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      String? profileURL = event.profileURL;
      if (profileURL != null) {
        final loading = CustomState(
          title: "Uploading Profile",
          message: "Please wait...",
        );
        _emit(loading: loading, emit);
        profileURL = await repo.uploadProfile(event.id, event.profileURL!);
      }

      final loading = CustomState(
        message: "Please wait...",
        title: "Updating User",
      );
      _emit(loading: loading, emit);

      user = await repo.updateUser(
        event.copyWith(profileURL: profileURL ?? user?.profileURL).toJson(),
      );

      event.onSuccess?.call();
      _emit(emit);
    } catch (e) {
      final error = CustomState(message: e.toString(), title: "Login Error");
      _emit(error: error, emit);
      event.onError?.call(error);
    }
  }

  Future<void> _onGetUser(AuthGetUser event, Emitter<AuthState> emit) async {
    try {
      user = await repo.getUser();
      if (user == null) throw "User not found";

      event.onSuccess?.call();
      _emit(emit);
    } catch (e) {
      final error = CustomState(message: e.toString(), title: "Login Error");
      _emit(error: error, emit);
      event.onError?.call(error);
    }
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    final loading = CustomState(message: "Please wait...", title: "Login");
    _emit(loading: loading, emit);

    try {
      user = await repo.login(event.toJson());
      event.onSuccess?.call();
      _emit(emit);
    } catch (e) {
      final error = CustomState(message: e.toString(), title: "Login Error");
      _emit(error: error, emit);
      event.onError?.call(error);
    }
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    final loading = CustomState(message: "Please wait...", title: "Signing up");
    _emit(loading: loading, emit);

    try {
      user = await repo.register(event.toJson());
      event.onSuccess?.call();
      _emit(emit);
    } catch (e) {
      final error = CustomState(message: e.toString(), title: "Register Error");
      _emit(error: error, emit);
      event.onError?.call(error);
    }
  }

  Future<void> _onGetCode(AuthGetCode event, Emitter<AuthState> emit) async {
    final loading = CustomState(
      message: "Please check your email app...",
      title: "Requesting Code",
    );
    _emit(loading: loading, emit);

    try {
      await repo.sendCode(event.toJson());
      event.onSuccess?.call();
      _emit(emit);
    } catch (e) {
      final error = CustomState(title: "Get Code Error", message: e.toString());
      _emit(error: error, emit);
      event.onError?.call(error);
    }
  }

  Future<void> _onUpdatePassword(
    AuthUpdatePassword event,
    Emitter<AuthState> emit,
  ) async {
    final loading = CustomState(
      title: "Updating Password",
      message: "Please wait...",
    );
    _emit(loading: loading, emit);

    try {
      await repo.updatePassword(event.toJson());
      event.onSuccess?.call();
      _emit(emit);
    } catch (e) {
      final error = CustomState(
        title: "Update Password Error",
        message: e.toString(),
      );
      _emit(error: error, emit);
      event.onError?.call(error);
    }
  }

  Future<void> _onVerifyCode(
    AuthVerifyCode event,
    Emitter<AuthState> emit,
  ) async {
    final loading = CustomState(
      message: "Please wait...",
      title: "Verifying Code",
    );
    _emit(loading: loading, emit);

    try {
      await repo.verifyCode(event.toJson());
      event.onSuccess?.call();
      _emit(emit);
    } catch (e) {
      final error = CustomState(
        title: "Verify Code Error",
        message: e.toString(),
      );
      _emit(error: error, emit);
      event.onError?.call(error);
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    final loading = CustomState(
      message: "Please wait...",
      title: "Logging out",
    );

    _emit(loading: loading, emit);
    await repo.logout();
    event.onSuccess?.call();
    _emit(emit);
  }

  void _emit(Emitter emit, {CustomState? loading, CustomState? error}) =>
      emit(AuthState(error: error, loading: loading, user: user));
}
