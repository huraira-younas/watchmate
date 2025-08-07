import 'package:watchmate_app/features/stream/views/widgets/build_title.dart';
import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/widgets/custom_checkbox.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class PlatformSelection extends StatelessWidget {
  final Function(VideoVisibility type) onVisibilityChange;
  final Function(VideoType type) onTypeChange;
  final VideoVisibility visibility;
  final VideoType type;

  const PlatformSelection({
    required this.onVisibilityChange,
    required this.onTypeChange,
    required this.visibility,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final titlesMap = {
      VideoVisibility.public.name:
          "Selecting public visibility allows all users on the platform to access the video. Play it or watch with others",
      VideoVisibility.private.name:
          "Selecting private visibility restricts access to you only. You can still watch it with others by creating a room and sharing the link.",
      "platform":
          "Please ensure the selected platform matches the link type. Invalid platform selections may result in download failure.",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PlatformTitle(title: "Select Platform", text: titlesMap["platform"]!),
        10.h,
        Row(
          spacing: 16,
          children: <Widget>[
            _buildOption<VideoType>(
              label: VideoType.youtube.name.capitalize,
              current: VideoType.youtube,
              onTap: onTypeChange,
              selected: type,
            ),
            _buildOption<VideoType>(
              label: VideoType.direct.name.capitalize,
              current: VideoType.direct,
              onTap: onTypeChange,
              selected: type,
            ),
          ],
        ),
        20.h,
        const MyText(
          text: "Select Visibility",
          size: AppConstants.title,
          family: AppFonts.bold,
        ),
        4.h,
        MyText(text: titlesMap[visibility.name]!, color: theme.hintColor),
        10.h,
        Row(
          spacing: 16,
          children: <Widget>[
            _buildOption<VideoVisibility>(
              label: VideoVisibility.public.name.capitalize,
              current: VideoVisibility.public,
              onTap: onVisibilityChange,
              selected: visibility,
            ),
            _buildOption<VideoVisibility>(
              label: VideoVisibility.private.name.capitalize,
              current: VideoVisibility.private,
              onTap: onVisibilityChange,
              selected: visibility,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption<T>({
    required Function(T) onTap,
    required String label,
    required T selected,
    required T current,
  }) {
    return Row(
      children: <Widget>[
        CustomCheckBox(isChecked: selected == current),
        10.w,
        MyText(family: AppFonts.bold, text: label),
      ],
    ).onTap(() => onTap(current));
  }
}
