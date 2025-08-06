import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                size: AppConstants.subtitle,
                family: AppFonts.bold,
                text: video.title,
              ),
              4.h,
              MyText(text: _buildInfoText(), size: 12, color: theme.hintColor),
            ],
          ).padAll(10),
        ],
      ),
    );
  }

  String _buildInfoText() {
    if (video is DownloadingVideo) {
      final downloading = video as DownloadingVideo;

      return "${downloading.percent.toStringAsFixed(1)}% downloaded • ${_formatSize(video.size)}";
    } else if (video is DownloadedVideo) {
      final downloaded = video as DownloadedVideo;
      final formatter = DateFormat('dd MMM yyyy');

      final date = formatter.format(downloaded.createdAt.toLocal());
      return "Downloaded on $date • ${_formatDuration(video.duration)} • ${_formatSize(video.size)}";
    } else {
      return "${_formatDuration(video.duration)} • ${_formatSize(video.size)}";
    }
  }

  String _formatSize(int size) {
    if (size >= 1 << 20) {
      return "${(size / (1 << 20)).toStringAsFixed(1)} MB";
    } else if (size >= 1 << 10) {
      return "${(size / (1 << 10)).toStringAsFixed(1)} KB";
    } else {
      return "$size B";
    }
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds.remainder(60);
    final minutes = duration.inMinutes;
    return "${minutes}m ${seconds}s";
  }
}
