import 'package:watchmate_app/screens/auth_screens/forgot_password_screen.dart';
import 'package:watchmate_app/screens/auth_screens/new_password_screen.dart';
import 'package:watchmate_app/screens/auth_screens/verify_code_screen.dart';
import 'package:watchmate_app/screens/splash_screen/splash_screen.dart';
import 'package:watchmate_app/screens/auth_screens/signup_screen.dart';
import 'package:watchmate_app/screens/auth_screens/login_screen.dart';
import 'app_route_model.dart';

abstract class AuthRoutes {
  static const splash = AppRoute(
    page: SplashScreen(),
    name: 'splash',
    path: '/',
  );

  static const login = AppRoute(
    page: LoginScreen(),
    path: '/login',
    name: 'login',
  );

  static const signup = AppRoute(
    page: SignupScreen(),
    path: '/sign_up',
    name: 'signup',
  );

  static const forgotPassword = AppRoute(
    page: ForgotPasswordScreen(),
    path: '/forgot_password',
    name: 'forgot_password',
  );

  static const verifyCode = AppRoute(
    page: VerifyCodeScreen(),
    path: '/verify_code',
    name: 'verify_code',
  );

  static const newPassword = AppRoute(
    page: NewPasswordScreen(),
    path: '/new_password',
    name: 'new_password',
  );

  static const all = [
    forgotPassword,
    newPassword,
    verifyCode,
    splash,
    signup,
    login,
  ];
}
