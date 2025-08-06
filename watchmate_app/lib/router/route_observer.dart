import 'package:flutter/widgets.dart' show Route, NavigatorObserver;
import 'package:watchmate_app/utils/logger.dart';

class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    Logger.info(tag: "ROUTER", message: '🧭 Pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    Logger.info(tag: "ROUTER", message: '🔙 Popped: ${route.settings.name}');
  }
}
