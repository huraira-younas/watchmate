import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/features/player/widgets/build_title_tile.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/features/player/widgets/room_chat.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/custom_player.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    required this.tagPrefix,
    required this.partyId,
    required this.video,
    super.key,
  });

  final DownloadedVideo video;
  final String tagPrefix;
  final String? partyId;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _expandedHeight = ValueNotifier<bool>(false);
  final _expanded = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayerBloc>(
      create: (_) => PlayerBloc(
        getIt<SocketNamespaceService>(),
        getIt<AuthBloc>().user!.id,
      ),
      lazy: false,
      child: Scaffold(
        appBar: customAppBar(context: context, title: "Player"),
        body: Column(
          children: <Widget>[
            CustomVideoPlayer(
              thumbnailURL: widget.video.thumbnailURL,
              tagPrefix: widget.tagPrefix,
              url: widget.video.videoURL,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _expanded,
              builder: (_, expand, _) {
                return Column(
                  children: <Widget>[
                    BuildTitleTile(video: widget.video, expand: !expand),
                    ValueListenableBuilder<bool>(
                      valueListenable: _expandedHeight,
                      builder: (_, expandedHeight, _) {
                        return RoomChat(
                          partyId: "327253c5-1b57-413a-bc88-930e23029cd6",
                          expandHeight: expandedHeight,
                          onExpand: toggleExpand,
                          expand: expand,
                        ).expanded();
                      },
                    ),
                  ],
                );
              },
            ).expanded(),
          ],
        ),
      ),
    );
  }

  void toggleExpand() {
    _expanded.value = !_expanded.value;
    Future.delayed(
      400.millis,
      () => _expandedHeight.value = !_expandedHeight.value,
    );
  }
}
