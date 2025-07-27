import 'package:watchmate_app/services/logger.dart';
import 'package:flutter/material.dart';

class Preloader {
  static final Map<String, List<String>> _routeAssets = {};

  static void register(String route, List<String> assetPaths) {
    if (_routeAssets.containsKey(route)) {
      _routeAssets[route] = [..._routeAssets[route]!, ...assetPaths];
    } else {
      _routeAssets[route] = assetPaths;
    }
  }

  static Future<void> preloadForRoute(
    BuildContext context,
    String route,
  ) async {
    final assets = _routeAssets[route];
    if (assets == null || assets.isEmpty) return;

    await Future.wait(
      assets.map((path) async {
        try {
          await precacheImage(AssetImage(path), context);
          Logger.success(tag: "ASSETS", message: "Preloaded: $path");
        } catch (e) {
          Logger.warn(tag: "ASSETS", message: "Failed to preload: $path → $e");
        }
      }),
    );
  }

  static Future<void> preloadGlobal(BuildContext context) async {
    await preloadForRoute(context, 'global');
  }
}
