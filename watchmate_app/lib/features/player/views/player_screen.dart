import 'package:watchmate_app/common/services/api_service/api_routes.dart';
import 'package:watchmate_app/common/services/api_service/dio_client.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_player.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({required this.videoId, super.key});
  final String videoId;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _uid = getIt<AuthBloc>().user!.id;
  final _api = ApiService();

  late final _future = _api.post(
    ApiRoutes.video.getVideo,
    data: {'userId': _uid, 'id': widget.videoId},
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: customAppBar(context: context, title: "Player"),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: LoadingAnimationWidget.threeRotatingDots(
                color: theme.primaryColor,
                size: 50,
              ).fadeIn(),
            );
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return const CustomLabelWidget(
              text: "The video you are looking for is deleted or removed",
              icon: Icons.error_outline,
              title: "Video not found",
            );
          }

          final response = snapshot.data!;
          if (response.statusCode != 200) {
            final error = response.error!;
            return CustomLabelWidget(
              icon: Icons.error_outline,
              title: "Error Getting Video",
              text: error,
            );
          }

          final video = DownloadedVideo.fromJson(response.body);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomVideoPlayer(
                thumbnailURL: video.thumbnailURL,
                url: video.videoURL,
              ),
              CustomChip(
                icon: Icons.private_connectivity_rounded,
                text: video.visibility.name.capitalize,
              ).padOnly(l: AppConstants.padding - 6, t: 10),
              CustomCard(
                child: MyText(
                  size: AppConstants.subtitle,
                  family: AppFonts.semibold,
                  text: video.title,
                ),
              ),
              Row(
                children: <Widget>[
                  const CustomChip(
                    icon: Icons.thumb_up_alt_outlined,
                    text: "1.2k",
                  ),
                  4.w,
                  const CustomChip(icon: Icons.share_outlined, text: "Share"),
                  4.w,
                  const CustomChip(
                    icon: Icons.download_outlined,
                    text: "Download",
                  ),
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
          );
        },
      ),
    );
  }
}
