import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class RoomChat extends StatelessWidget {
  const RoomChat({
    required this.expandHeight,
    required this.onExpand,
    required this.expand,
    super.key,
  });

  final VoidCallback onExpand;
  final bool expandHeight;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AnimatedPadding(
      duration: 100.millis,
      padding: EdgeInsetsGeometry.all(expandHeight ? 0.0 : 10.0),
      child: CustomCard(
        margin: 0.0,
        constraints: BoxConstraints(minHeight: context.screenHeight * 0.3),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            const CustomLabelWidget(
              text: "Senpai is building this. Please have a seat",
              title: "RealTime Chat Area",
              icon: Icons.chair,
            ),
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                onPressed: onExpand,
                icon: Icon(
                  expand
                      ? Icons.expand_more_outlined
                      : Icons.expand_less_outlined,
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
