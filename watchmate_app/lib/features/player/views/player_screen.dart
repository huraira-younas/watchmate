import 'package:watchmate_app/common/widgets/custom_video_player/custom_player.dart';
import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/features/player/widgets/build_chips.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/features/player/widgets/room_chat.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
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
  final _hide = ValueNotifier<bool>(false);

  late final SocketNamespaceService _socket;
  late final PlayerBloc _playerBloc;
  late final String _uid;

  @override
  Widget build(BuildContext context) {
    final partyId = widget.partyId;

    return BlocProvider.value(
      value: _playerBloc,
      child: Scaffold(
        appBar: customAppBar(context: context, title: "Video Player"),
        body: Column(
          children: <Widget>[
            CustomVideoPlayer(
              isOwner: partyId == null || partyId == _uid,
              tagPrefix: widget.tagPrefix,
              video: widget.video,
              partyId: partyId,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _expanded,
              builder: (_, expand, _) {
                return Column(
                  children: <Widget>[
                    BuildChips(video: widget.video, expand: !expand),
                    ValueListenableBuilder<bool>(
                      valueListenable: _expandedHeight,
                      builder: (_, expandedHeight, _) {
                        return RoomChat(
                          expandHeight: expandedHeight,
                          videoId: widget.video.id,
                          onExpand: toggleExpand,
                          partyId: partyId,
                          expand: expand,
                          userId: _uid,
                          hide: _hide,
                        ).expanded();
                      },
                    ),
                  ],
                );
              },
            ).expanded(),
          ],
        ).safeArea(t: false),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _socket = getIt<SocketNamespaceService>();
    _uid = getIt<AuthBloc>().user!.id;
    _unregisterPlayerBloc();

    _playerBloc = PlayerBloc(_socket, _uid);
    getIt.registerLazySingleton<PlayerBloc>(() => _playerBloc);
  }

  @override
  void dispose() {
    _expandedHeight.dispose();
    _unregisterPlayerBloc();
    _expanded.dispose();
    _hide.dispose();
    super.dispose();
  }

  void _unregisterPlayerBloc() {
    if (getIt.isRegistered<PlayerBloc>()) {
      getIt<PlayerBloc>().close();
      getIt.unregister<PlayerBloc>();
    }
  }

  void toggleHide() => _hide.value = !_hide.value;
  void toggleExpand() {
    _expanded.value = !_expanded.value;
    Future.delayed(
      400.millis,
      () => _expandedHeight.value = !_expandedHeight.value,
    );
  }
}
