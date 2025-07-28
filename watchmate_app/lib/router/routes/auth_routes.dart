import 'package:watchmate_app/features/auth/views/forgot_password_screen.dart';
import 'package:watchmate_app/features/auth/views/new_password_screen.dart';
import 'package:watchmate_app/features/auth/views/verify_code_screen.dart';
import 'package:watchmate_app/features/auth/views/signup_screen.dart';
import 'package:watchmate_app/features/auth/views/login_screen.dart';
import 'package:watchmate_app/features/splash/splash_screen.dart';
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
