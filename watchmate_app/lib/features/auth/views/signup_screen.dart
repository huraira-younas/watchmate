import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/router/routes/exports.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final _userBloc = getIt<AuthBloc>();

  final _controllers = List.generate(4, (index) => TextEditingController());
  final _keys = List.generate(4, (index) => GlobalKey<FormState>());
  final _obsecures = List.generate(2, (_) => true);

  void _signup() {
    if (_keys.any((e) => !e.currentState!.validate())) {
      return;
    }

    final password = _controllers[2].text.trim();
    final email = _controllers[1].text.trim();
    final name = _controllers[0].text.trim();

    _userBloc.add(
      AuthRegister(
        onSuccess: () => context.pop(),
        password: password,
        email: email,
        name: name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    final theme = context.theme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              20.h,
              Image.asset(
                AppAssets.icons.appIcon,
                width: size.width * 0.5,
              ).hero(LayoutRoutes.homeLayout.name),
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
              ).padSym(h: 30),
              40.h,
              Form(
                key: _keys[0],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  validator: ValidatorBuilder.chain().required().min(3).build(),
                  prefixIcon: const Icon(Icons.person_outline),
                  controller: _controllers[0],
                  hint: "Name",
                ),
              ),
              10.h,
              Form(
                key: _keys[1],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  prefixIcon: const Icon(Icons.email_outlined),
                  controller: _controllers[1],
                  validator: ValidatorBuilder.chain()
                      .required()
                      .email()
                      .min(6)
                      .build(),
                  hint: "Email",
                ),
              ),
              10.h,
              Form(
                key: _keys[2],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  validator: ValidatorBuilder.chain().required().min(8).build(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  controller: _controllers[2],
                  obsecure: _obsecures[0],
                  hint: "Password",
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obsecures[0] = !_obsecures[0]),
                    icon: Icon(
                      _obsecures[0]
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ),
              10.h,
              Form(
                key: _keys[3],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  validator: ValidatorBuilder.chain()
                      .required()
                      .oneOf(() => _controllers[2].text, "Passwords must match")
                      .build(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  controller: _controllers[3],
                  obsecure: _obsecures[1],
                  hint: "Confirm Password",
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obsecures[1] = !_obsecures[1]),
                    icon: Icon(
                      _obsecures[1]
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ),
              20.h,
              CustomButton(text: "Sign up", onPressed: _signup),
              20.h,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const MyText(
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
      ).onTap(() => context.unfocus()),
    );
  }

  @override
  void dispose() {
    _controllers.asMap().forEach((i, c) => c.dispose());
    super.dispose();
  }
}
