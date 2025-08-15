import 'package:watchmate_app/features/player/widgets/bottom_builder.dart';
import 'package:watchmate_app/features/player/widgets/body_builder.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class RoomChat extends StatelessWidget {
  const RoomChat({
    required this.expandHeight,
    required this.onExpand,
    required this.partyId,
    required this.videoId,
    required this.expand,
    super.key,
  });

  final VoidCallback onExpand;
  final bool expandHeight;
  final String? partyId;
  final String videoId;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AnimatedPadding(
      duration: 100.millis,
      padding: EdgeInsetsGeometry.all(expandHeight ? 0.0 : 10.0),
      child: CustomCard(
        padding: 8,
        margin: 0.0,
        radius: expandHeight ? 0 : 10,
        constraints: BoxConstraints(minHeight: context.screenHeight * 0.3),
        child: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            final joined = state.joined;
            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    BodyBuilder(
                      messages: state.messages,
                      videoId: videoId,
                      partyId: partyId,
                      joined: joined,
                    ).expanded(),
                    if (joined > 1) const BottomBuilder(),
                  ],
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: IconButton(
                    onPressed: onExpand,
                    icon: Icon(
                      expand ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: theme.hintColor,
                    ),
                  ),
                ),
                CustomChip(
                  text: "Joined ${joined == -1 ? 0 : joined}",
                  icon: Icons.supervised_user_circle_sharp,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
