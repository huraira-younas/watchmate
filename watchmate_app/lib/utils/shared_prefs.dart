import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPrefs get instance => _instance;
  late SharedPreferences _prefs;

  static final SharedPrefs _instance = SharedPrefs._internal();
  SharedPrefs._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ------------------ Theme ------------------
  static const _keyIsDarkMode = 'is_dark_mode';

  bool get isDarkMode => _prefs.getBool(_keyIsDarkMode) ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyIsDarkMode, value);
  }

  // ------------------ User ------------------
  static const _keyUser = 'logged_user';

  String? getLoggedUser() => _prefs.getString(_keyUser);

  Future<void> setLoggedUser(String id) async {
    await _prefs.setString(_keyUser, id);
  }

  Future<void> removeLoggedUser() async {
    await _prefs.remove(_keyUser);
  }

  // ------------------ Generic Methods ------------------

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  Future<void> remove(String key) async => await _prefs.remove(key);

  double getDouble(String key) => _prefs.getDouble(key) ?? 0.0;

  bool getBool(String key) => _prefs.getBool(key) ?? false;

  String? getString(String key) => _prefs.getString(key);

  Future<void> clearAll() async => await _prefs.clear();

  int getInt(String key) => _prefs.getInt(key) ?? 0;
}
