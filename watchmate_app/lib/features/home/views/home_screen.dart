import 'package:watchmate_app/common/widgets/hls_player.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[Center(child: HlsVideoPlayer(folder: "test_video"))],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
