import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: MyText(text: "MyList"),
    );
  }
}
