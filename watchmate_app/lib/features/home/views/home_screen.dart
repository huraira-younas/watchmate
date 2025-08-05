import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
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

    return const CustomLabelWidget(
      text: "The page you're looking for is under development",
      title: "Senpai is working",
      icon: Icons.wash_outlined,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
