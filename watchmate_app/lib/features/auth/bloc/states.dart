import '../model/user_model.dart';

class AuthState {
  final UserModel? user;
  final String? error;
  final bool loading;

  AuthState({this.user, this.loading = false, this.error});
  bool get loggedIn => user != null;

  AuthState copyWith({String? error, bool? loading, UserModel? user}) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      user: user,
    );
  }
}
