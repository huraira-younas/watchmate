import 'package:watchmate_app/router/routes/exports.dart';

abstract class AppRoutes {
  static const auth = AuthRoutes.all;

  static const all = [...auth];
}
