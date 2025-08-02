import 'package:watchmate_app/features/home/views/widgets/history_builder.dart';
import 'package:watchmate_app/features/home/views/widgets/custom_chip.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class StreamTab extends StatelessWidget {
  const StreamTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = myStyle(
      color: theme.textTheme.bodyLarge?.color ?? Colors.black,
      family: AppFonts.semibold,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: MyText(
              text: "Start streaming with your link.",
              size: AppConstants.titleLarge,
              family: AppFonts.bold,
            ),
          ),
          20.h,
          RichText(
            text: TextSpan(
              text: "You can ",
              style: textStyle,
              children: <TextSpan>[
                TextSpan(
                  style: textStyle.copyWith(color: theme.primaryColor),
                  text: "stream",
                ),
                TextSpan(text: " & "),
                TextSpan(
                  style: textStyle.copyWith(color: theme.primaryColor),
                  text: "download",
                ),
                TextSpan(text: " with "),
              ],
            ),
          ),
          10.h,
          CustomChip(icon: Icons.add_link, text: "HTTP link"),
          30.h,
          SizedBox(
            width: 300,
            child: MyText(
              text: "Or Upload video file for everyone on the platform.",
              size: AppConstants.titleLarge,
              family: AppFonts.bold,
            ),
          ),
          20.h,
          RichText(
            text: TextSpan(
              text: "You can ",
              style: textStyle,
              children: <TextSpan>[
                TextSpan(
                  style: textStyle.copyWith(color: theme.primaryColor),
                  text: "upload",
                ),
                TextSpan(text: " local files to "),
                TextSpan(
                  style: textStyle.copyWith(color: theme.primaryColor),
                  text: "server",
                ),
                TextSpan(text: " with extensions "),
              ],
            ),
          ),
          10.h,
          Row(
            children: <Widget>[
              CustomChip(icon: Icons.upload_file, text: ".mkv"),
              10.w,
              CustomChip(icon: Icons.upload_file, text: ".mp4"),
            ],
          ),
          30.h,
          Row(
            children: <Widget>[
              CustomButton(
                borderColor: theme.primaryColor,
                textColor: theme.primaryColor,
                bgColor: Colors.transparent,
                text: "Upload File",
                onPressed: () {},
                radius: 20,
              ).expanded(),
              10.w,
              CustomButton(
                text: "Stream Link",
                radius: 20,
                onPressed: () {},
              ).expanded(),
            ],
          ),
          30.h,
          HistoryBuilder(),
        ],
      ),
    );
  }
}
