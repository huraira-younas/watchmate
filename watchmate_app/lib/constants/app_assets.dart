import 'package:watchmate_app/services/pre_loader.dart';

class Illustrations {
  late final String _base;
  final String _pre;

  Illustrations(this._pre) {
    _base = '$_pre/illustrations';
  }

  String get login => '$_base/login.png';

  List<String> get preloadList => [login];
}

class AppAssets {
  static const _pre = "assets";
  static const _images = "$_pre/images";

  static final illustrations = Illustrations(_images);

  static void registerPreloads() {
    Preloader.register('global', [...illustrations.preloadList]);
    Preloader.register('login', [illustrations.login]);
  }
}
