import 'package:watchmate_app/features/stream/views/link_screen.dart';
import 'package:watchmate_app/features/stream/views/stream_screen.dart';
import 'package:flutter/material.dart' show Icons;
import 'app_route_model.dart';

abstract class StreamRoutes {
  static const stream = AppRoute(
    icon: Icons.settings_input_antenna_rounded,
    page: StreamScreen(),
    path: '/stream',
    name: 'Stream',
  );

  static const link = AppRoute(
    path: '/stream_link',
    page: LinkScreen(),
    name: 'Link',
  );

  static final all = [stream, link];
}
