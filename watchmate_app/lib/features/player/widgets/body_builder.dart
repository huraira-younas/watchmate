import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/common/widgets/message_reaction_wrapper.dart';
import 'package:watchmate_app/features/player/model/reaction_model.dart';
import 'package:watchmate_app/features/player/widgets/message_tile.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/utils/share_service.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/common/swipe_msg.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class BodyBuilder extends StatefulWidget {
  const BodyBuilder({
    required this.messages,
    required this.partyId,
    required this.videoId,
    required this.joined,
    super.key,
  });

  final List<PartyMessageModel> messages;
  final String? partyId;
  final String videoId;
  final int joined;

  @override
  State<BodyBuilder> createState() => _BodyBuilderState();
}

class _BodyBuilderState extends State<BodyBuilder> {
  final _user = getIt<AuthBloc>().user!;
  late final _scroller = ScrollController();
  final _playerBloc = getIt<PlayerBloc>();

  void _handleReaction(String emoji, PartyMessageModel msg) {
    final reactions = [...msg.reactions];
    final userId = _user.id;

    final idx = reactions.indexWhere((e) => e.userId == userId);

    if (idx != -1) {
      if (reactions[idx].react == emoji) {
        reactions.removeAt(idx);
      } else {
        reactions[idx] = Reaction(
          profileURL: _user.profileURL ?? "",
          name: _user.name,
          userId: userId,
          react: emoji,
        );
      }
    } else {
      reactions.add(
        Reaction(
          profileURL: _user.profileURL ?? "",
          name: _user.name,
          userId: userId,
          react: emoji,
        ),
      );
    }

    final updatedMessage = msg.copyWith(reactions: reactions);
    _playerBloc.add(
      ReactMessage(
        partyId: _playerBloc.partyId ?? widget.partyId!,
        message: updatedMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    final joined = widget.joined;
    final theme = context.theme;
    final closed = joined == -1;

    if ((joined == 1 || closed) && messages.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          30.h,
          CustomLabelWidget(
            text: closed
                ? "Create new watch party and share link with your friends to watch together"
                : "Share link with your friends to watch together",
            title: closed ? "Party Closed" : "Watch with friends",
            icon: Icons.signpost,
            iconSize: 50,
          ),
          5.h,
          TextButton(
            onPressed: _createParty,
            style: TextButton.styleFrom(backgroundColor: theme.cardColor),
            child: const MyText(text: "Share Watch Party"),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 35, bottom: 20),
      separatorBuilder: (_, _) => 12.h,
      itemCount: messages.length,
      controller: _scroller,
      itemBuilder: (_, idx) {
        final msg = messages[idx];
        final isMe = msg.userId == _user.id;
        final isOwner = widget.partyId == msg.userId;

        return SwipeMsg(
          onSwipe: () => _playerBloc.add(
            ReplyMessage(message: msg, partyId: widget.partyId!),
          ),
          allowedDirection: isMe ? SwipeDirection.left : SwipeDirection.right,
          child: MessageReactionWrapper(
            onSelect: (emoji) => _handleReaction(emoji, msg),
            isSender: isMe,
            child: MessageTile(
              isOwner: isOwner,
              userId: _user.id,
              isMe: isMe,
              msg: msg,
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant BodyBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroller.hasClients) {
          _scroller.animateTo(
            _scroller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _createParty() async {
    final userId = _user.id;
    _playerBloc.add(CreateParty(userId: userId));
    ShareService.sharePartyLink(widget.videoId, userId);
  }

  @override
  void initState() {
    super.initState();
    if (widget.partyId != null) {
      _playerBloc.add(JoinParty(partyId: widget.partyId!, userId: _user.id));
    }
  }
}
