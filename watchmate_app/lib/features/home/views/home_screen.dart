import 'package:watchmate_app/common/widgets/hls_player.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: HlsVideoPlayer(folder: "test_video")),
    );
  }
}
