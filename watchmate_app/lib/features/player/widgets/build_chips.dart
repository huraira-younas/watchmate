import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/features/player/widgets/download_chip.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/utils/share_service.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class BuildChips extends StatelessWidget {
  const BuildChips({super.key, required this.video, required this.expand});
  final DownloadedVideo video;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: expand ? 53 : 0,
      duration: 100.millis,
      child: SingleChildScrollView(
        child: AnimatedOpacity(
          duration: 200.millis,
          opacity: expand ? 1 : 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                spacing: 4,
                children: <Widget>[
                  CustomChip(
                    icon: video.visibility.name == "public"
                        ? Icons.language
                        : Icons.private_connectivity_rounded,
                    text: video.visibility.name.capitalize,
                  ),
                  CustomChip(
                    onPressed: () => ShareService.shareVideoLink(video.id),
                    icon: Icons.share_outlined,
                    text: "Share",
                  ),
                  DownloadChip(video: video),
                ],
              ).padSym(h: AppConstants.padding - 6, v: 20),
            ],
          ),
        ),
      ),
    );
  }
}
