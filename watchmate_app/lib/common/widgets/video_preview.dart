import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class VideoPreview extends StatelessWidget {
  const VideoPreview({super.key, required this.video});
  final BaseVideo video;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CacheImage(url: video.thumbnailURL),
          ),
          6.h,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MyText(
                text: video.title,
                size: AppConstants.subtitle,
                family: AppFonts.bold,
              ),
              2.h,
              if (video is DownloadingVideo)
                MyText(
                  text:
                      "${(video as DownloadingVideo).percent.toStringAsFixed(1)}% downloaded",
                  size: 12,
                )
              else if (video is DownloadedVideo)
                MyText(
                  text:
                      "Downloaded on ${(video as DownloadedVideo).createdAt.toLocal()}",
                  size: 12,
                ),
            ],
          ).padAll(10),
        ],
      ),
    );
  }
}
