import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_player.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key, required this.video});
  final BaseVideo video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Player"),
      body: Column(
        children: <Widget>[
          CustomVideoPlayer(url: video.videoURL),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomChip(
                icon: Icons.private_connectivity_rounded,
                text: video.visibility.name.capitalize,
              ),
              10.h,
              MyText(
                family: AppFonts.semibold,
                size: AppConstants.title,
                text: video.title,
              ),
            ],
          ).padAll(AppConstants.padding - 10),
          Row(
            children: <Widget>[
              const CustomChip(icon: Icons.thumb_up_alt_outlined, text: "1.2k"),
              4.w,
              const CustomChip(
                icon: Icons.thumb_down_alt_outlined,
                text: "Dislike",
              ),
              4.w,
              const CustomChip(icon: Icons.share_outlined, text: "Share"),
              4.w,
              const CustomChip(icon: Icons.download_outlined, text: "Download"),
            ],
          ).padSym(h: AppConstants.padding - 10),
        ],
      ),
    );
  }
}
