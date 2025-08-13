import 'package:watchmate_app/features/player/widgets/bottom_builder.dart';
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
        padding: 8,
        constraints: BoxConstraints(minHeight: context.screenHeight * 0.3),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SingleChildScrollView(
                  child: CustomLabelWidget(
                    text: "Senpai is building this. Please have a seat",
                    title: "RealTime Chat Area",
                    icon: Icons.chair,
                  ),
                ).expanded(),
                const BottomBuilder(),
              ],
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
