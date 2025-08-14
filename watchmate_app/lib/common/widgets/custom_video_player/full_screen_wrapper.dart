import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_video_controls.dart';
import 'package:chewie/chewie.dart';
import 'dart:async' show Timer;

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
      body: Stack(
        children: <Widget>[
          Chewie(
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
          const ChatOverlay(),
        ],
      ),
    );
  }
}

class ChatOverlay extends StatefulWidget {
  const ChatOverlay({super.key});

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  List<PartyMessageModel> visibleMessages = [];
  bool _show = true;
  Timer? _timer;

  void _showMessages(List<PartyMessageModel> latest) {
    setState(() {
      visibleMessages = latest;
      _show = true;
    });

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: BlocListener<PlayerBloc, PlayerState>(
        listenWhen: (previous, current) =>
            previous.messages != current.messages,
        listener: (context, state) {
          final latest = state.messages.length > 3
              ? state.messages.sublist(state.messages.length - 3)
              : state.messages;
          _showMessages(latest);
        },
        child: AnimatedOpacity(
          opacity: !_show ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 500),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: visibleMessages.map((msg) {
                  return ListTile(
                    subtitle: MyText(text: msg.message, size: 10),
                    title: MyText(text: msg.name, size: 12),
                    contentPadding: EdgeInsets.zero,
                    minTileHeight: 0,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
