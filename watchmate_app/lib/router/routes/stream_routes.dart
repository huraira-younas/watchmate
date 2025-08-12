import 'package:watchmate_app/router/custom_transitions/bottom_up_transition.dart';
import 'package:watchmate_app/features/stream/views/upload_screen.dart';
import 'package:watchmate_app/features/player/views/player_screen.dart';
import 'package:watchmate_app/features/stream/views/stream_screen.dart';
import 'package:watchmate_app/features/stream/views/link_screen.dart';
import 'package:watchmate_app/router/not_found_page.dart';
import 'package:flutter/material.dart' show Icons;
import 'app_route_model.dart';

abstract class StreamRoutes {
  static const stream = AppRoute(
    icon: Icons.wifi_tethering,
    page: StreamScreen(),
    path: '/stream',
    name: 'Stream',
  );

  static const link = AppRoute(
    path: '/stream_link',
    page: LinkScreen(),
    name: 'Link',
  );

  static const upload = AppRoute(
    path: '/upload_file',
    page: UploadScreen(),
    name: 'Upload',
  );

  static final player = AppRoute(
    path: '/player',
    name: 'Player',
    pageBuilder: (context, state) {
      final query = state.uri.queryParameters;
      String? id = query['id'];

      id ??= state.extra as String?;
      if (id == null || id.isEmpty) {
        return bottomUpTransition(
          key: state.pageKey,
          child: const NotFoundPage(
            message: 'Video ID missing or invalid link',
            title: 'Error Getting Video',
          ),
        );
      }

      return bottomUpTransition(
        child: PlayerScreen(videoId: id),
        key: state.pageKey,
      );
    },
  );

  static final all = [stream, link, player, upload];
}
