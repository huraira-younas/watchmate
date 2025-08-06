import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_player.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key, required this.video});
  final BaseVideo video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Player"),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CustomVideoPlayer(url: video.videoURL),
            const MyText(
              text: "Invite your friends to watch together",
              size: AppConstants.title,
              family: AppFonts.bold,
            ),
          ],
        ),
      ),
    );
  }
}
