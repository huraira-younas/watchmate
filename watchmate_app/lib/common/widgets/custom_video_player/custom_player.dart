import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:watchmate_app/features/player/model/video_state_model.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'build_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({
    required this.tagPrefix,
    required this.isOwner,
    required this.partyId,
    required this.video,
    super.key,
  });

  final DownloadedVideo video;
  final String tagPrefix;
  final String? partyId;
  final bool isOwner;

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  double? _aspectRatio;

  late final isOwner = widget.isOwner;
  late String? partyId = widget.partyId;
  late final video = widget.video;

  Duration _lastPosition = Duration.zero;
  bool _lastIsPlaying = false;

  void _emitVideoState() {
    partyId ??= getIt<PlayerBloc>().partyId;
    if (!isOwner || partyId == null) {
      Logger.info(tag: "PLAYER", message: "Not leader or no partyId");
      return;
    }

    final controller = _videoPlayerController;
    if (!controller.value.isInitialized) {
      Logger.info(tag: "PLAYER", message: "Controller not initialized");
      return;
    }

    final playing = controller.value.isPlaying;
    final pos = controller.value.position;
    final diff = pos - _lastPosition;

    if (playing == _lastIsPlaying && diff.inSeconds.abs() <= 2) {
      return;
    }

    _lastIsPlaying = playing;
    _lastPosition = pos;

    final state = VideoState(
      playbackSpeed: controller.value.playbackSpeed,
      lastUpdate: DateTime.now(),
      isPlaying: playing,
      position: pos,
    );

    Logger.info(tag: "PLAYER", message: "State: ${state.toString()}");

    context.read<PlayerBloc>().add(
      HandleVideoState(videoState: state, partyId: partyId!),
    );
  }

  Future<void> _initPlayer() async {
    Logger.info(tag: "PLAYER", message: "PartyId: $partyId");
    Logger.info(tag: "PLAYER", message: "Owner: $isOwner");
    final cleanUrl = video.videoURL.replaceAll('"', '');

    Logger.info(tag: "PLAYING", message: Uri.parse(cleanUrl));
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(cleanUrl),
    );
    await _videoPlayerController.initialize();
    final size = _videoPlayerController.value.size;
    _aspectRatio = size.width / size.height;

    if (isOwner) _videoPlayerController.addListener(_emitVideoState);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: _aspectRatio ?? (16 / 9),
      autoPlay: partyId == null,
      hideControlsTimer: 3.secs,
      allowFullScreen: false,
      showOptions: false,
      allowMuting: true,
      looping: false,
    );

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _chewieController?.removeListener(_emitVideoState);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final loading =
        _chewieController == null ||
        !_chewieController!.videoPlayerController.value.isInitialized;

    final double maxHeight = context.screenHeight * 0.43;

    final double arHeight = context.screenWidth / (_aspectRatio ?? (16 / 9));
    final double finalHeight = arHeight < maxHeight ? arHeight : maxHeight;

    return AnimatedContainer(
      height: loading ? arHeight : finalHeight,
      width: context.screenWidth,
      duration: 100.millis,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(video.thumbnailURL)),
        color: theme.cardColor.withValues(alpha: 0.2),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : AspectRatio(
              aspectRatio: _aspectRatio ?? (16 / 9),
              child: BuildPlayer(
                controller: _chewieController!,
                title: video.title,
                isOwner: isOwner,
              ),
            ),
    ).hero("${widget.tagPrefix}:${video.thumbnailURL}");
  }
}
