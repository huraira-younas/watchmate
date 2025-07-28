import 'package:watchmate_app/common_widget/custom_button.dart';
import 'package:watchmate_app/common_widget/text_widget.dart';
import 'package:watchmate_app/common_widget/text_field.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/services/pre_loader.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/cubits/theme_cubit.dart';
import 'package:watchmate_app/router/route_paths.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final themeCubit = context.read<ThemeCubit>();

  final _controllers = List.generate(2, (index) => TextEditingController());
  final _keys = List.generate(2, (index) => GlobalKey<FormState>());
  bool _obsecure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = themeCubit.isDark;
    final size = context.screenSize;
    final theme = context.theme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              20.h,
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => themeCubit.toggleTheme(),
                  icon: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                    color: theme.colorScheme.primary,
                    size: 26,
                  ),
                ),
              ),
              Image.asset(
                AppAssets.icons.appIcon,
                width: size.width * 0.5,
              ).hero(AppConstants.appname),
              20.h,
              MyText(
                size: size.width * 0.08,
                family: AppFonts.bold,
                text: "Welcome Back!",
                isCenter: true,
              ),
              5.h,
              MyText(
                text: "Please login to your account",
                size: AppConstants.subtitle,
                color: theme.hintColor,
                isCenter: true,
              ),
              40.h,
              Form(
                key: _keys[0],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  prefixIcon: const Icon(Icons.email_outlined),
                  controller: _controllers[0],
                  hint: "Email",
                ),
              ),
              10.h,
              Form(
                key: _keys[1],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  prefixIcon: const Icon(Icons.lock_outline),
                  controller: _controllers[1],
                  obsecure: _obsecure,
                  hint: "Password",
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obsecure = !_obsecure),
                    icon: Icon(
                      _obsecure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: MyText(
                    color: theme.colorScheme.primary,
                    size: AppConstants.subtitle,
                    family: AppFonts.semibold,
                    text: "Forgot password?",
                  ),
                ),
              ),
              20.h,
              CustomButton(text: "Login", onPressed: () {}),
              20.h,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MyText(
                    text: "Don't have an account?",
                    size: AppConstants.subtitle,
                  ),
                  TextButton(
                    onPressed: () => context.push(RoutePaths.signup),
                    child: MyText(
                      color: theme.colorScheme.primary,
                      size: AppConstants.subtitle,
                      text: "Sign up",
                    ),
                  ),
                ],
              ),
              60.h,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.asMap().forEach((i, c) => c.dispose());
    super.dispose();
  }

  bool _isLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoaded) return;

    Preloader.preloadForRoute(context, 'login');
    _isLoaded = true;
  }
}
