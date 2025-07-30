import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: MyText(text: "Downloads"),
    );
  }
}
