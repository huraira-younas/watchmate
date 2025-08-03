import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/extensions/num_entensions.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class BuildTitle extends StatelessWidget {
  final String title;
  final String s1;
  final String c1;
  final String s2;
  final String c2;
  final String s3;
  final double w;
  const BuildTitle({
    required this.title,
    required this.s1,
    required this.c1,
    required this.s2,
    required this.c2,
    required this.s3,
    this.w = 200,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = myStyle(
      color: theme.textTheme.bodyLarge?.color ?? Colors.black,
      size: AppConstants.subtitle,
      family: AppFonts.semibold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: w,
          child: MyText(
            size: AppConstants.titleLarge * 1.3,
            family: AppFonts.bold,
            text: title,
          ),
        ),
        20.h,
        RichText(
          text: TextSpan(
            text: "$s1 ",
            style: textStyle,
            children: <TextSpan>[
              TextSpan(
                style: textStyle.copyWith(color: theme.primaryColor),
                text: c1,
              ),
              TextSpan(text: " $s2 "),
              TextSpan(
                style: textStyle.copyWith(color: theme.primaryColor),
                text: c2,
              ),
              TextSpan(text: " $s3 "),
            ],
          ),
        ),
      ],
    );
  }
}
