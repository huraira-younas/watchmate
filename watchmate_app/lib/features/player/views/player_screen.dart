import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_player.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomVideoPlayer(url: video.videoURL),
          CustomChip(
            icon: Icons.private_connectivity_rounded,
            text: video.visibility.name.capitalize,
          ).padOnly(l: AppConstants.padding - 6, t: 10),
          CustomCard(
            child: MyText(
              family: AppFonts.semibold,
              size: AppConstants.title,
              text: video.title,
            ),
          ),
          Row(
            children: <Widget>[
              const CustomChip(icon: Icons.thumb_up_alt_outlined, text: "1.2k"),
              4.w,
              const CustomChip(icon: Icons.share_outlined, text: "Share"),
              4.w,
              const CustomChip(icon: Icons.download_outlined, text: "Download"),
            ],
          ).padSym(h: AppConstants.padding - 6),
          const CustomCard(
            child: CustomLabelWidget(
              text: "Senpai is building this. Please have a seat",
              title: "RealTime Chat Area",
              icon: Icons.chair,
            ),
          ).expanded(),
        ],
      ),
    );
  }
}
