import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/extensions/string_extensions.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class CustomTabs extends StatelessWidget {
  const CustomTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: List.generate(
        VideoVisibility.values.length,
        (idx) => Chip(
          label: MyText(text: VideoVisibility.values[idx].name.capitalize),
        ),
      ),
    );
  }
}
