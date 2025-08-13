import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Function(String?)? onChange;
  final Function()? onSubmit;
  final FocusNode? focusNode;
  final InputBorder? border;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType type;
  final bool showTitle;
  final bool obsecure;
  final String? value;
  final String? label;
  final int? minLines;
  final int? maxLines;
  final double radius;
  final bool enabled;
  final String hint;

  const CustomTextField({
    this.type = TextInputType.text,
    this.showTitle = false,
    this.obsecure = false,
    this.enabled = true,
    required this.hint,
    this.maxLines = 1,
    this.radius = 30,
    this.prefixIcon,
    this.controller,
    this.suffixIcon,
    this.validator,
    this.focusNode,
    this.onChange,
    this.onSubmit,
    this.minLines,
    this.border,
    this.label,
    this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          MyText(
            family: AppFonts.semibold,
            text: label ?? hint,
            color: textColor,
          ),
        const SizedBox(height: 6),
        MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScaleFactor(context))),
          child: TextFormField(
            style: myStyle(size: AppConstants.subtitle, color: textColor),
            onFieldSubmitted: (_) => onSubmit?.call(),
            onTapOutside: (_) => onSubmit?.call(),
            onSaved: (_) => onSubmit?.call(),
            controller: controller,
            obscureText: obsecure,
            focusNode: focusNode,
            validator: validator,
            onChanged: onChange,
            initialValue: value,
            minLines: minLines,
            keyboardType: type,
            maxLines: maxLines,
            enabled: enabled,
            decoration: customInputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              context: context,
              radius: radius,
              border: border,
              hint: hint,
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration customInputDecoration({
  required BuildContext context,
  InputBorder? border,
  Widget? prefixIcon,
  Widget? suffixIcon,
  double radius = 30,
  String? label,
  String? hint,
}) {
  final theme = Theme.of(context);
  final Color hintColor = theme.hintColor.withValues(alpha: 0.7);
  final Color fillColor = theme.cardColor.withValues(alpha: 0.2);
  final textColor = theme.textTheme.bodyLarge?.color;

  final defaultBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(color: theme.highlightColor),
    borderRadius: BorderRadius.circular(radius),
  );

  final activeBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(color: theme.primaryColor),
    borderRadius: BorderRadius.circular(radius),
  );

  return InputDecoration(
    contentPadding: const EdgeInsets.only(top: 14, bottom: 12, right: 16),
    disabledBorder: border ?? defaultBorderStyle,
    enabledBorder: border ?? defaultBorderStyle,
    focusedBorder: border ?? activeBorderStyle,
    errorBorder: border ?? defaultBorderStyle,
    labelStyle: TextStyle(color: textColor),
    hintStyle: TextStyle(color: hintColor),
    border: border ?? defaultBorderStyle,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    fillColor: fillColor,
    isCollapsed: true,
    labelText: label,
    errorMaxLines: 3,
    hintText: hint,
    isDense: true,
    filled: true,
  );
}
