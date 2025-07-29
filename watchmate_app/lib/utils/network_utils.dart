import 'package:flutter/foundation.dart' show kDebugMode;

class NetworkUtils {
  static const _defaultLocalUrl = 'http://192.168.1.6:$_defaultPort';
  static const _defaultPort = 5000;

  static String get prodUrl => "https://4df5fed0-26d0-4913-980b-18bc46d9b32d-00-1fp1uf95mtg0y.pike.replit.dev";
  static String get baseUrl => kDebugMode ? _defaultLocalUrl : prodUrl;
}
