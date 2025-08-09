import 'package:watchmate_app/common/services/api_service/api_routes.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/common/widgets/profile_avt.dart';
import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

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
        color: theme.cardColor.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: <Widget>[
                CacheImage(
                  url: ApiRoutes.stream.getThumbnail(url: video.thumbnailURL),
                ),
                if (video.duration.inSeconds != 0)
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
          _buildBottom(color: theme.hintColor),
        ],
      ),
    ).onTap(
      () => !isDownloading
          ? context.push(StreamRoutes.player.path, extra: video)
          : null,
    );
  }

  Widget _buildBottom({required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (video is DownloadedVideo)
          ProfileAvt(
            url: (video as DownloadedVideo).user.fullProfileURL,
            size: 40,
          ),
        10.w,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MyText(
                  overflow: TextOverflow.ellipsis,
                  size: AppConstants.subtitle,
                  family: AppFonts.bold,
                  text: video.title,
                  maxLines: 2,
                ),
                3.h,
                MyText(text: _buildInfoText(), size: 12, color: color),
              ],
            ).expanded(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_outlined),
            ),
          ],
        ).expanded(),
      ],
    ).padAll(10);
  }

  String _buildInfoText() {
    if (video is DownloadingVideo) {
      final downloading = video as DownloadingVideo;

      return "${downloading.percent.toStringAsFixed(1)}% downloaded • ${video.sizeFormat}";
    } else if (video is DownloadedVideo) {
      final downloaded = video as DownloadedVideo;

      return "${downloaded.getRelativeTime()} • ${video.sizeFormat}";
    } else {
      return video.sizeFormat;
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
