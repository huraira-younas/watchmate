import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/router/routes/auth_routes.dart';
import 'package:watchmate_app/utils/pre_loader.dart';

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

class AppBackgrounds {
  late final String _base;

  AppBackgrounds({required String pre}) {
    _base = '$pre/backgrounds';
  }

  String get streamBg => '$_base/stream.jpg';
  List<String> get preloadList => [streamBg];
}

class AppAssets {
  static const _pre = "assets";
  static const _images = "$_pre/images";

  static final backgrounds = AppBackgrounds(pre: _images);
  static final icons = AppIcons(pre: _images);

  static void registerPreloads() {
    Preloader.register('global', [
      ...backgrounds.preloadList,
      ...icons.preloadList,
    ]);

    Preloader.register(StreamRoutes.stream.name, [...backgrounds.preloadList]);
    Preloader.register(AuthRoutes.login.name, [...icons.preloadList]);
  }
}
