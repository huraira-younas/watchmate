import 'package:watchmate_app/common/services/api_service/api_routes.dart';
import 'package:watchmate_app/common/services/api_service/dio_client.dart';
import 'package:watchmate_app/utils/shared_prefs.dart';
import '../model/user_model.dart';

class AuthRepository {
  final _sp = SharedPrefs.instance;
  final _api = ApiService();

  Future<UserModel?> getUser() async {
    final uid = _sp.getLoggedUser();
    if (uid == null) return null;

    final response = await _api.post(
      ApiRoutes.auth.getUser,
      data: {"uid": uid},
    );

    if (response.error != null) throw response.error!;
    final user = UserModel.fromJson(response.body);
    _sp.setLoggedUser(user.id);

    return user;
  }

  Future<UserModel> login(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.auth.login, data: data);
    if (response.error != null) throw response.error!;

    final user = UserModel.fromJson(response.body);
    _sp.setLoggedUser(user.id);

    return user;
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.auth.register, data: data);
    if (response.error != null) throw response.error!;

    final user = UserModel.fromJson(response.body);
    _sp.setLoggedUser(user.id);

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

  Future<String> updatePassword(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.auth.resetPassword, data: data);
    if (response.error != null) throw response.error!;
    return response.body.toString();
  }

  Future<String> uploadProfile(String userId, String profileURL) async {
    final res = await _api.upload(
      url: ApiRoutes.file.upload,
      filePath: profileURL,
      userId: userId,
    );

    return res.body;
  }

  Future<UserModel> updateUser(Map<String, dynamic> data) async {
    final response = await _api.post(ApiRoutes.auth.updateUser, data: data);
    if (response.error != null) throw response.error!;
    final user = UserModel.fromJson(response.body);
    return user;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sp.removeLoggedUser();
  }
}
