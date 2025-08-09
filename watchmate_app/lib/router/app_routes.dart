import 'package:go_router/go_router.dart' show GoRouterState;
import 'package:watchmate_app/router/routes/exports.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:watchmate_app/utils/shared_prefs.dart';

abstract class AppRoutes {
  static final layout = LayoutRoutes.all;
  static final stream = StreamRoutes.all;
  static final auth = AuthRoutes.all;

  static String? handle(BuildContext cyx, GoRouterState state) {
    final user = SharedPrefs.instance.getLoggedUser();
    if (user == null) return AuthRoutes.login.path;

    return null;
  }

  static final all = [LayoutRoutes.homeLayout, ...auth, ...stream];
}
