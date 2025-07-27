import 'package:watchmate_app/common_widget/custom_button.dart';
import 'package:watchmate_app/common_widget/text_widget.dart';
import 'package:watchmate_app/common_widget/text_field.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/services/pre_loader.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/cubits/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final themeCubit = context.read<ThemeCubit>();

  final _controllers = List.generate(4, (index) => TextEditingController());
  final _keys = List.generate(4, (index) => GlobalKey<FormState>());
  bool _obsecure = true;

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              20.h,
              Image.asset(AppAssets.illustrations.login),
              20.h,
              MyText(
                size: size.width * 0.08,
                family: AppFonts.bold,
                text: "Create Account",
                isCenter: true,
              ),
              5.h,
              MyText(
                text:
                    "Feel free to create new account on ${AppConstants.appname.capitalize}",
                size: AppConstants.subtitle,
                color: theme.hintColor,
                isCenter: true,
              ),
              40.h,
              Form(
                key: _keys[1],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  prefixIcon: const Icon(Icons.person_outline),
                  controller: _controllers[1],
                  hint: "Name",
                ),
              ),
              10.h,
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
                key: _keys[2],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  prefixIcon: const Icon(Icons.lock_outline),
                  controller: _controllers[2],
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
              20.h,
              CustomButton(text: "Sign up", onPressed: () {}),
              20.h,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MyText(
                    text: "Already have account?",
                    size: AppConstants.subtitle,
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: MyText(
                      color: theme.colorScheme.primary,
                      size: AppConstants.subtitle,
                      text: "Login",
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
