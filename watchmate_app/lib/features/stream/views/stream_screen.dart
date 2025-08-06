import 'package:watchmate_app/features/stream/views/widgets/build_background.dart';
import 'package:watchmate_app/features/stream/views/widgets/history_builder.dart';
import 'package:watchmate_app/features/stream/views/widgets/build_title.dart';
import 'package:watchmate_app/common/widgets/custom_button.dart';
import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/utils/pre_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class StreamScreen extends StatefulWidget {
  const StreamScreen({super.key});

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          const BuildBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                30.h,
                const BuildTitle(
                  title: "Start streaming with your link.",
                  s1: "You can",
                  c2: "download",
                  c1: "stream",
                  s3: "with",
                  s2: "&",
                ),
                10.h,
                const CustomChip(icon: Icons.add_link, text: "HTTP link"),
                30.h,
                const BuildTitle(
                  title: "Or Upload video file for everyone on the platform.",
                  s3: "with extensions",
                  s2: "local files to",
                  s1: "You can",
                  c2: "server",
                  c1: "upload",
                  w: 300,
                ),
                10.h,
                Row(
                  children: <Widget>[
                    const CustomChip(icon: Icons.upload_file, text: ".mkv"),
                    10.w,
                    const CustomChip(icon: Icons.upload_file, text: ".mp4"),
                  ],
                ),
                30.h,
                Row(
                  children: <Widget>[
                    CustomButton(
                      borderColor: theme.primaryColor,
                      textColor: theme.primaryColor,
                      bgColor: Colors.transparent,
                      text: "Upload File",
                      onPressed: () {},
                      radius: 20,
                    ).expanded(),
                    10.w,
                    CustomButton(
                      onPressed: () => context.push(StreamRoutes.link.path),
                      text: "Stream Link",
                      radius: 20,
                    ).expanded(),
                  ],
                ),
                30.h,
                const HistoryBuilder(),
              ],
            ),
          ).safeArea(),
        ],
      ),
    );
  }

  bool _isLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoaded) return;

    Preloader.preloadForRoute(context, StreamRoutes.stream.name);
    _isLoaded = true;
  }
}
