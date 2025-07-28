import 'package:watchmate_app/router/routes/auth_routes.dart';

abstract class AppRoutes {
  static const auth = AuthRoutes.all;

  static const all = [...auth];
}
