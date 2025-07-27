import 'package:watchmate_app/services/logger.dart';
import 'package:watchmate_app/services/shared_prefs.dart';
import 'package:watchmate_app/constants/app_themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeData> {
  final _sp = SharedPrefs.instance;
  ThemeCubit() : super(AppThemes.lightTheme) {
    init(_sp.isDarkMode);
  }

  bool get isDark => state.brightness == Brightness.dark;

  Future<void> init(bool dark) async {
    Logger.info(tag: "THEME", message: "${dark ? "Dark" : "Light"} Theme");
    emit(_sp.isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme);
  }

  Future<void> toggleTheme() async {
    final newTheme = isDark ? AppThemes.lightTheme : AppThemes.darkTheme;
    _sp.setDarkMode(!isDark);
    emit(newTheme);
  }

  Future<void> setDark() async {
    emit(AppThemes.darkTheme);
    _sp.setDarkMode(true);
  }

  Future<void> setLight() async {
    emit(AppThemes.lightTheme);
    _sp.setDarkMode(false);
  }
}
