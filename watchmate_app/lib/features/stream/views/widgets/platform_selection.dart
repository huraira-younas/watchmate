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
          "Setting visibility to Public makes the video accessible to all platform users. This allows for public playback and shared viewing experiences.",
      VideoVisibility.private.name:
          "Setting visibility to Private restricts access to your account only. You can still share the video with others by creating and sharing a private room link.",
      VideoType.direct.name:
          "Please provide a valid URL for a direct video from a website. URLs from other platforms like Facebook, X, or Instagram are not supported and may not function correctly.",
      VideoType.youtube.name:
          "To ensure a successful download, please provide a valid YouTube URL. URLs from other video platforms are not compatible with this feature.",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PlatformTitle(title: "Select Platform", text: titlesMap[type.name]!),
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
