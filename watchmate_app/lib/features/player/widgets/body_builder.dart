import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/common/widgets/profile_avt.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/utils/share_service.dart';
import 'package:watchmate_app/extensions/exports.dart';
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
  final _userId = getIt<AuthBloc>().user!.id;
  late final _scroller = ScrollController();
  final _playerBloc = getIt<PlayerBloc>();

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    final joined = widget.joined;
    final theme = context.theme;

    if ((joined == 1 || joined == -1) && messages.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          30.h,
          CustomLabelWidget(
            text: joined == -1
                ? "Create new watch party and share link with your friends to watch together"
                : "Share link with your friends to watch together",
            title: joined == -1
                ? "Watch party disclosed"
                : "Watch with friends",
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
      padding: const EdgeInsets.only(top: 35, bottom: 10),
      separatorBuilder: (_, _) => 12.h,
      itemCount: messages.length,
      controller: _scroller,
      itemBuilder: (_, idx) {
        final msg = messages[idx];
        final isMe = msg.userId == _userId;
        final isOwner = _playerBloc.partyId == msg.userId;

        return Align(
          alignment: isMe ? Alignment.topRight : Alignment.topLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: <Widget>[
              if (!isMe) ProfileAvt(size: 40, url: msg.profileURL),
              Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    spacing: 4,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (isOwner && isMe)
                        Image.asset(AppAssets.icons.crownIcon, height: 14),
                      MyText(
                        text: isMe ? "You" : msg.name.capitalize,
                        size: AppConstants.subtitle,
                        family: AppFonts.bold,
                      ),
                      if (isOwner && !isMe)
                        Image.asset(AppAssets.icons.crownIcon, height: 14),
                    ],
                  ),
                  MyText(text: msg.message),
                ],
              ).flexible(),
              if (isMe) ProfileAvt(size: 40, url: msg.profileURL),
            ],
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
    _playerBloc.add(CreateParty(userId: _userId));
    ShareService.sharePartyLink(widget.videoId, _userId);
  }

  @override
  void initState() {
    super.initState();
    if (widget.partyId != null) {
      _playerBloc.add(JoinParty(partyId: widget.partyId!, userId: _userId));
    }
  }
}
