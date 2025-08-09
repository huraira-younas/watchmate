import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class HistoryBuilder extends StatelessWidget {
  const HistoryBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const MyText(family: AppFonts.semibold, text: "History"),
            10.w,
            const Icon(Icons.delete_outline),
          ],
        ),
        70.h,
        const CustomLabelWidget(
          text: "Upload file or stream link to get history.",
          title: "No History Found",
          icon: Icons.ac_unit,
          iconSize: 60,
        ),
      ],
    );
  }
}
