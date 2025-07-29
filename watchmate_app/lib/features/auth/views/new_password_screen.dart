import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/auth/bloc/events.dart';
import 'package:watchmate_app/router/routes/auth_routes.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  late final _userBloc = getIt<AuthBloc>();

  final _controllers = List.generate(2, (index) => TextEditingController());
  final _keys = List.generate(2, (index) => GlobalKey<FormState>());

  void _update() {
    if (_keys.any((e) => !e.currentState!.validate())) {
      return;
    }

    _userBloc.add(
      AuthUpdatePassword(
        onSuccess: () => context.go(AuthRoutes.login.path),
        newPassword: _controllers[0].text.trim(),
        email: widget.email,
        method: "forget",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    final theme = context.theme;

    return Scaffold(
      appBar: customAppBar(context: context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              20.h,
              Image.asset(
                AppAssets.icons.passwordIcon,
                width: size.width * 0.5,
              ).hero(AppConstants.appname),
              20.h,
              MyText(
                size: size.width * 0.08,
                family: AppFonts.bold,
                text: "Create New Password",
                isCenter: true,
              ),
              5.h,
              MyText(
                text: "Create a secure and complex password for your account",
                size: AppConstants.subtitle,
                color: theme.hintColor,
                isCenter: true,
              ).padSym(h: 30),
              40.h,
              Form(
                key: _keys[0],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  validator: ValidatorBuilder.chain().required().min(8).build(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  controller: _controllers[0],
                  hint: "New Password",
                ),
              ),
              10.h,
              Form(
                key: _keys[1],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hint: "Confirm New Password",
                  controller: _controllers[1],
                  validator: ValidatorBuilder.chain()
                      .required()
                      .oneOf(() => _controllers[0].text, "Passwords must match")
                      .build(),
                ),
              ),
              20.h,
              CustomButton(onPressed: _update, text: "Update Password"),
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
}
