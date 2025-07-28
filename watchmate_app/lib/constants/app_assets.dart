import 'package:watchmate_app/router/routes/auth_routes.dart';
import 'package:watchmate_app/services/pre_loader.dart';

class AppIcons {
  late final String _base;

  AppIcons({required String pre}) {
    _base = '$pre/icons';
  }

  String get passwordIcon => '$_base/password.png';
  String get appIcon => '$_base/app_icon.png';
  String get emailIcon => '$_base/email.png';
  String get codeIcon => '$_base/code.png';

  List<String> get preloadList => [appIcon, codeIcon, emailIcon, passwordIcon];
}

class AppAssets {
  static const _pre = "assets";
  static const _images = "$_pre/images";

  static final icons = AppIcons(pre: _images);

  static void registerPreloads() {
    Preloader.register('global', [...icons.preloadList]);

    Preloader.register(AuthRoutes.login.name, [...icons.preloadList]);
  }
}
