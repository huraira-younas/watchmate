import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class VideoCardPreview extends StatelessWidget {
  const VideoCardPreview({
    required this.onMenuTap,
    required this.video,
    super.key,
  });

  final VoidCallback onMenuTap;
  final DownloadedVideo video;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ListTile(
      onTap: () => context.push(StreamRoutes.player.path, extra: video.id),
      horizontalTitleGap: 8,
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: SizedBox(
          height: 90,
          width: 100,
          child: CacheImage(url: video.thumbnailURL),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_outlined),
        onPressed: onMenuTap,
      ),
      subtitle: MyText(
        text: _buildInfoText(),
        color: theme.hintColor,
        size: 11,
      ),
      title: MyText(
        overflow: TextOverflow.ellipsis,
        family: AppFonts.semibold,
        text: video.title,
        maxLines: 2,
        size: 12,
      ),
    );
  }

  String _buildInfoText() {
    return "${video.sizeFormat} • ${video.getRelativeTime()}";
  }
}
