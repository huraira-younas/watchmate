import 'package:watchmate_app/services/api_service/api_routes.dart';
import 'package:watchmate_app/services/api_service/dio_client.dart';
import 'package:watchmate_app/services/shared_prefs.dart';
import '../model/user_model.dart';

class AuthRepository {
  final _api = ApiService();

  Future<UserModel> login(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.auth.login, data: data);
    if (response.error != null) throw response.error!;

    final user = UserModel.fromJson(response.body);
    SharedPrefs.instance.setLoggedUser(user.id);

    return user;
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.auth.register, data: data);
    if (response.error != null) throw response.error!;

    final user = UserModel.fromJson(response.body);
    SharedPrefs.instance.setLoggedUser(user.id);

    return user;
  }

  Future<String> sendCode(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.auth.sendCode, data: data);
    if (response.error != null) throw response.error!;
    return response.body.toString();
  }

  Future<String> verifyCode(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.auth.verifyCode, data: data);
    if (response.error != null) throw response.error!;
    return response.body.toString();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    SharedPrefs.instance.removeLoggedUser();
  }
}
