import 'package:watchmate_app/services/pre_loader.dart';
import 'package:watchmate_app/router/route_paths.dart';

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

  static final icons = AppIcons(_images);

  static void registerPreloads() {
    Preloader.register('global', [...icons.preloadList]);

    Preloader.register(RoutePaths.splash, [icons.appIcon]);
    Preloader.register(RoutePaths.login, [icons.appIcon]);
  }
}
