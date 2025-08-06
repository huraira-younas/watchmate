import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VideoPreview extends StatelessWidget {
  const VideoPreview({super.key, required this.video});
  final BaseVideo video;

  @override
  Widget build(BuildContext context) {
    final isDownloading = video is DownloadingVideo;
    final theme = context.theme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: <Widget>[
                CacheImage(url: video.thumbnailURL),
                Positioned(
                  right: 3,
                  bottom: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: theme.cardColor,
                    ),
                    child: MyText(
                      text: _formatDuration(video.duration),
                      family: AppFonts.semibold,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
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
    ).onTap(
      () => !isDownloading
          ? context.push(StreamRoutes.player.path, extra: video)
          : null,
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
      return "Downloaded on $date • ${_formatSize(video.size)}";
    } else {
      return _formatSize(video.size);
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
    final s = duration.inSeconds.remainder(60);
    final m = duration.inMinutes.remainder(60);
    final h = duration.inHours;

    if (h > 0) {
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }

    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}
