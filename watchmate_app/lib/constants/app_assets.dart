import 'package:watchmate_app/services/pre_loader.dart';
import 'package:watchmate_app/router/route_paths.dart';

class AppIllustrations {
  late final String _base;
  final String _pre;

  AppIllustrations(this._pre) {
    _base = '$_pre/illustrations';
  }

  String get login => '$_base/login.png';

  List<String> get preloadList => [login];
}

class AppIcons {
  late final String _base;
  final String _pre;

  AppIcons(this._pre) {
    _base = '$_pre/icons';
  }

  String get appIcon => '$_base/app_icon.png';

  List<String> get preloadList => [appIcon];
}

class AppAssets {
  static const _pre = "assets";
  static const _images = "$_pre/images";

  static final illustrations = AppIllustrations(_images);
  static final icons = AppIcons(_images);

  static void registerPreloads() {
    Preloader.register('global', [
      ...illustrations.preloadList,
      ...icons.preloadList,
    ]);

    Preloader.register(RoutePaths.login, [illustrations.login]);
    Preloader.register(RoutePaths.splash, [icons.appIcon]);
  }
}
