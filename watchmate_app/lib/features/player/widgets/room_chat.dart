import 'package:watchmate_app/features/player/widgets/bottom_builder.dart';
import 'package:watchmate_app/features/player/widgets/body_builder.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/custom_chip.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class RoomChat extends StatelessWidget {
  const RoomChat({
    required this.expandHeight,
    required this.onExpand,
    required this.partyId,
    required this.videoId,
    required this.expand,
    required this.userId,
    required this.hide,
    super.key,
  });

  final VoidCallback onExpand;
  final ValueNotifier hide;
  final bool expandHeight;
  final String? partyId;
  final String videoId;
  final String userId;
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
          buildWhen: (p, c) =>
              p.messages.length != c.messages.length || p.joined != c.joined,
          builder: (context, state) {
            bool isImOwner = userId == state.partyId || partyId == null;
            final joined = state.joined;
            final isClosed = joined == -1;

            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: hide,
                  builder: (_, value, _) {
                    return AnimatedSwitcher(
                      duration: 150.millis,
                      child: value
                          ? const CustomLabelWidget(
                              text: "To unhide messages click on Toggle Hide",
                              icon: Icons.hide_source_sharp,
                              title: "Messages are hidden",
                            ).center()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                BodyBuilder(
                                  partyId: state.partyId ?? partyId,
                                  messages: state.messages,
                                  videoId: videoId,
                                  joined: joined,
                                ).expanded(),
                                if (joined > 1) const BottomBuilder(),
                              ],
                            ),
                    );
                  },
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
                AnimatedOpacity(
                  opacity: isClosed ? 0 : 1,
                  duration: 100.millis,
                  child: Row(
                    spacing: 10,
                    children: <Widget>[
                      CustomChip(
                        text: "Joined ${joined == -1 ? 0 : joined}",
                        icon: Icons.supervised_user_circle_sharp,
                      ),
                      ValueListenableBuilder(
                        valueListenable: hide,
                        builder: (_, value, _) {
                          return CustomChip(
                            icon: !value
                                ? Icons.toggle_off_outlined
                                : Icons.toggle_on,
                            text: !value ? "Hide" : "Unhide",
                          ).onTap(() => hide.value = !hide.value);
                        },
                      ),
                      if (isImOwner && state.partyId != null)
                        const CustomChip(
                          text: "Close Party",
                          icon: Icons.close,
                        ).onGesture(
                          onTap: () => getIt<PlayerBloc>().add(
                            CloseParty(userId: userId),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
