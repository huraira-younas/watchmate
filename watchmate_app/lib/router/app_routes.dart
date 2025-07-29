import 'package:watchmate_app/router/routes/exports.dart';

abstract class AppRoutes {
  static final auth = AuthRoutes.all;

  static final all = [...auth];
}
