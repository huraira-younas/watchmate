import 'package:watchmate_app/screens/auth_screens/signup_screen.dart';
import 'package:watchmate_app/screens/auth_screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';

final routes = <GoRoute>[
  GoRoute(path: RoutePaths.signup, builder: (_, _) => const SignupScreen()),
  GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginScreen()),
];
