import 'package:flutter/foundation.dart' show kDebugMode;

class NetworkUtils {
  static const _defaultLocalUrl = 'http://192.168.1.5:$_defaultPort';
  static String get prodUrl => "https://watchmate.hurairayounas.com";
  static const _defaultPort = 5000;

  static String get baseUrl => kDebugMode ? _defaultLocalUrl : prodUrl;
}
