import 'package:watchmate_app/common/models/custom_state_model.dart';
import '../model/user_model.dart';

class AuthState {
  final CustomState? loading;
  final CustomState? error;
  final UserModel? user;

  AuthState({this.user, this.loading, this.error});
  bool get loggedIn => user != null;

  AuthState copyWith({
    CustomState? loading,
    CustomState? error,
    UserModel? user,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      user: user,
    );
  }
}

class CustomState extends BaseCustomState {
  CustomState({required super.message, required super.title});
}
