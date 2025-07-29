import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/auth/bloc/events.dart';
import 'package:watchmate_app/features/auth/bloc/states.dart';
import 'package:watchmate_app/router/routes/auth_routes.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final _userBloc = getIt<AuthBloc>();

  final _controllers = List.generate(1, (index) => TextEditingController());
  final _keys = List.generate(1, (index) => GlobalKey<FormState>());

  void _sendCode() {
    if (_keys.any((e) => !e.currentState!.validate())) {
      return;
    }

    final email = _controllers[0].text.trim();
    _userBloc.add(AuthGetCode(email: email));
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
              30.h,
              Image.asset(
                AppAssets.icons.codeIcon,
                width: size.width * 0.5,
              ).hero(AppConstants.appname),
              20.h,
              MyText(
                size: size.width * 0.08,
                family: AppFonts.bold,
                text: "Get Code",
                isCenter: true,
              ),
              5.h,
              MyText(
                text: "Enter registered email address to get one time code.",
                size: AppConstants.subtitle,
                color: theme.hintColor,
                isCenter: true,
              ).padSym(h: 30),
              40.h,
              Form(
                key: _keys[0],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  prefixIcon: const Icon(Icons.email_outlined),
                  controller: _controllers[0],
                  hint: "Email",
                  validator: ValidatorBuilder.chain()
                      .required()
                      .email()
                      .min(6)
                      .build(),
                ),
              ),
              20.h,
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.loading == null && state.error == null) {
                    context.push(
                      AuthRoutes.verifyCode.path,
                      extra: _controllers[0].text.trim(),
                    );
                  }
                },
                child: CustomButton(onPressed: _sendCode, text: "Get Code"),
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
}
