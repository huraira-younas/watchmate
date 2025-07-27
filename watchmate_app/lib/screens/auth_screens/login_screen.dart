import 'package:watchmate_app/common_widget/custom_button.dart';
import 'package:watchmate_app/common_widget/text_widget.dart';
import 'package:watchmate_app/common_widget/text_field.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/services/pre_loader.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/cubits/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final size = MediaQuery.of(context).size;
    final isDark = themeCubit.isDark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
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
              Image.asset(AppAssets.illustrations.login),
              const SizedBox(height: 20),
              MyText(
                text: "Welcome Back!",
                family: AppFonts.bold,
                size: size.width * 0.08,
                isCenter: true,
              ),
              const SizedBox(height: 5),
              MyText(
                text: "Please login to your account",
                color: theme.hintColor,
                size: AppConstants.subtitle,
                isCenter: true,
              ),
              const SizedBox(height: 40),
              Form(
                key: _keys[0],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  prefixIcon: const Icon(Icons.email_outlined),
                  controller: _controllers[0],
                  hint: "Email",
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              CustomButton(text: "Login", onPressed: () {}),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MyText(
                    text: "Don't have an account?",
                    size: AppConstants.subtitle,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: MyText(
                      color: theme.colorScheme.primary,
                      size: AppConstants.subtitle,
                      text: "Sign up",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
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
