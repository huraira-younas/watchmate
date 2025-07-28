import 'package:flutter/foundation.dart' show kDebugMode;

class NetworkUtils {
  static const _defaultLocalUrl = 'http://192.168.1.11:$_defaultPort';
  static const _defaultPort = 5000;

  static String get prodUrl => "https://api.yourdomain.com";
  static String get baseUrl => kDebugMode ? _defaultLocalUrl : prodUrl;
}
