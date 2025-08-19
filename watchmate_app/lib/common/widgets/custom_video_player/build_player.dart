import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';
import 'custom_video_controls.dart';
import 'package:chewie/chewie.dart';
import 'full_screen_wrapper.dart';

class BuildPlayer extends StatelessWidget {
  const BuildPlayer({
    required this.controller,
    required this.isOwner,
    required this.title,
    super.key,
  });

  final ChewieController controller;
  final bool isOwner;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (prev, curr) => prev.videoState != curr.videoState,
      listener: (context, state) {
        final videoState = state.videoState;
        if (videoState == null || isOwner) return;

        final videoPlayer = controller.videoPlayerController;
        final currentPos = videoPlayer.value.position;
        final diff = (videoState.position - currentPos).inMilliseconds.abs();

        if (diff > 5000) {
          videoPlayer.seekTo(videoState.position);
        }

        if (videoState.isPlaying && !videoPlayer.value.isPlaying) {
          videoPlayer.play();
        } else if (!videoState.isPlaying && videoPlayer.value.isPlaying) {
          videoPlayer.pause();
        }

        if (videoState.playbackSpeed != videoPlayer.value.playbackSpeed) {
          videoPlayer.setPlaybackSpeed(videoState.playbackSpeed);
        }
      },

      child: BlocBuilder<PlayerBloc, PlayerState>(
        buildWhen: (p, c) => c.joined == -1,
        builder: (context, state) {
          final closed = state.joined == -1;
          return Chewie(
            controller: controller.copyWith(
              customControls: CustomVideoControls(
                controller: controller.videoPlayerController,
                isOwner: closed || isOwner,
                isFullScreen: false,
                title: title,
                seekPad: 0,
                toggleScreen: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: getIt<PlayerBloc>(),
                      child: FullScreenWrapper(
                        isOwner: closed || isOwner,
                        controller: controller,
                        title: title,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
