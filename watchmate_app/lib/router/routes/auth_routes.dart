import 'package:watchmate_app/features/auth/views/forgot_password_screen.dart';
import 'package:watchmate_app/features/profile/views/edit_profile_screen.dart';
import 'package:watchmate_app/features/auth/views/new_password_screen.dart';
import 'package:watchmate_app/features/auth/views/verify_code_screen.dart';
import 'package:watchmate_app/features/auth/views/signup_screen.dart';
import 'package:watchmate_app/features/auth/views/login_screen.dart';
import 'package:watchmate_app/features/auth/model/user_model.dart';
import 'package:watchmate_app/features/splash/splash_screen.dart';
import 'package:flutter/material.dart' show Icons;
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

  static final verifyCode = AppRoute(
    path: '/verify_code',
    name: 'verify_code',
    builder: (context, state) {
      final email = state.extra as String;
      return VerifyCodeScreen(email: email);
    },
  );

  static final newPassword = AppRoute(
    path: '/new_password',
    name: 'new_password',
    builder: (context, state) {
      final email = state.extra as String;
      return NewPasswordScreen(email: email);
    },
  );

  static final editProfile = AppRoute(
    path: '/edit_profile',
    name: 'Edit Profile',
    icon: Icons.edit,
    builder: (context, state) {
      final user = state.extra as UserModel;
      return EditProfileScreen(user: user);
    },
  );

  static final all = [
    forgotPassword,
    editProfile,
    newPassword,
    verifyCode,
    splash,
    signup,
    login,
  ];
}
