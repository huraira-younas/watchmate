import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/router/routes/auth_routes.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/common/cubits/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show
        LengthLimitingTextInputFormatter,
        FilteringTextInputFormatter,
        LogicalKeyboardKey;

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _keyboardNodes = List.generate(6, (_) => FocusNode());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  late final themeCubit = context.read<ThemeCubit>();

  String get otp => _controllers.map((e) => e.text).join();

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
              ).hero(AppConstants.appname),
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
              CustomButton(
                text: "Verify",
                onPressed: () {
                  context.pushReplacement(AuthRoutes.newPassword.path);
                },
              ),
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
