import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_video_controls.dart';
import 'package:chewie/chewie.dart';

class FullScreenWrapper extends StatefulWidget {
  final ChewieController controller;
  final String title;
  final bool isOwner;

  const FullScreenWrapper({
    required this.controller,
    required this.isOwner,
    required this.title,
    super.key,
  });

  @override
  State<FullScreenWrapper> createState() => _FullScreenWrapperState();
}

class _FullScreenWrapperState extends State<FullScreenWrapper> {
  late final controller = widget.controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void deactivate() {
    super.deactivate();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chewie(
        controller: controller.copyWith(
          customControls: CustomVideoControls(
            toggleScreen: () => Navigator.of(context).pop(),
            controller: controller.videoPlayerController,
            isOwner: widget.isOwner,
            title: widget.title,
            seekPad: 20,
          ),
        ),
      ),
    );
  }
}
