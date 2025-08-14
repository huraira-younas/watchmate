import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/utils/share_service.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class BuildTitleTile extends StatelessWidget {
  const BuildTitleTile({super.key, required this.video, required this.expand});
  final DownloadedVideo video;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: expand ? 130 : 0,
      duration: 100.millis,
      child: SingleChildScrollView(
        child: AnimatedOpacity(
          duration: 200.millis,
          opacity: expand ? 1 : 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomChip(
                icon: video.visibility.name == "public"
                    ? Icons.language
                    : Icons.private_connectivity_rounded,
                text: video.visibility.name.capitalize,
              ).padOnly(l: AppConstants.padding - 6, t: 10),
              CustomCard(
                child: MyText(
                  overflow: TextOverflow.ellipsis,
                  size: AppConstants.subtitle,
                  family: AppFonts.semibold,
                  text: video.title,
                  maxLines: 1,
                ),
              ),
              Row(
                children: <Widget>[
                  const CustomChip(
                    icon: Icons.thumb_up_alt_outlined,
                    text: "1.2k",
                  ),
                  4.w,
                  CustomChip(
                    onPressed: () => ShareService.shareVideoLink(video.id),
                    icon: Icons.share_outlined,
                    text: "Share",
                  ),
                  4.w,
                  const CustomChip(
                    icon: Icons.download_outlined,
                    text: "Download",
                  ),
                ],
              ).padSym(h: AppConstants.padding - 6),
            ],
          ),
        ),
      ),
    );
  }
}
