import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/utils/validator_builder.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/router/routes/exports.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show
        LengthLimitingTextInputFormatter,
        FilteringTextInputFormatter,
        LogicalKeyboardKey;

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  late final _userBloc = getIt<AuthBloc>();

  final _controllers = List.generate(6, (_) => TextEditingController());
  final _keyboardNodes = List.generate(6, (_) => FocusNode());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  void _verify() {
    final code = _controllers.map((e) => e.text).join();

    final validator = ValidatorBuilder.chain().required().min(6).build();
    if (validator(code) != null) return;

    final email = widget.email;
    _userBloc.add(
      AuthVerifyCode(
        code: code,
        email: email,
        onSuccess: () {
          context.push(AuthRoutes.newPassword.path, extra: email);
        },
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
              30.h,
              Image.asset(
                AppAssets.icons.emailIcon,
                width: size.width * 0.5,
              ).hero(LayoutRoutes.homeLayout.name),
              20.h,
              MyText(
                size: size.width * 0.08,
                family: AppFonts.bold,
                text: "Verify Code",
                isCenter: true,
              ),
              5.h,
              MyText(
                text: "Enter the 6-digit code we just sent to your email.",
                size: AppConstants.subtitle,
                color: theme.hintColor,
                isCenter: true,
              ).padSym(h: 30),
              40.h,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 45,
                    child: KeyboardListener(
                      focusNode: _keyboardNodes[i],
                      onKeyEvent: (value) {
                        if (value.logicalKey == LogicalKeyboardKey.backspace) {
                          if (_controllers[i].text.isEmpty && i > 0) {
                            _focusNodes[i - 1].requestFocus();
                            _controllers[i - 1].clear();
                          }
                        }
                      },
                      child: TextField(
                        onChanged: (val) => _onChanged(val, i),
                        keyboardType: TextInputType.number,
                        controller: _controllers[i],
                        textAlign: TextAlign.center,
                        focusNode: _focusNodes[i],
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.bold,
                          fontSize: 24,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: const EdgeInsets.all(10),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.highlightColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              30.h,
              CustomButton(onPressed: _verify, text: "Verify"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _keyboardNodes.asMap().forEach((i, f) => f.dispose());
    _controllers.asMap().forEach((i, c) => c.dispose());
    _focusNodes.asMap().forEach((i, f) => f.dispose());
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }
}
