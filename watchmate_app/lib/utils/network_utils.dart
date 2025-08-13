import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkUtils {
  static final _defaultLocalUrl = dotenv.get("DEV_URL", fallback: "");
  static String get prodUrl => dotenv.get("PROD_URL", fallback: "");

  static String get baseUrl => !kDebugMode ? _defaultLocalUrl : prodUrl;
}
