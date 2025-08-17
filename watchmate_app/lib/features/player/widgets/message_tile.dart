import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/features/player/widgets/reaction_row.dart';
import 'package:watchmate_app/extensions/string_extensions.dart';
import 'package:watchmate_app/extensions/widget_extensions.dart';
import 'package:watchmate_app/common/widgets/custom_card.dart';
import 'package:watchmate_app/common/widgets/profile_avt.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final PartyMessageModel msg;
  final String userId;
  final bool isOwner;
  final bool isMe;

  const MessageTile({
    required this.isOwner,
    required this.userId,
    required this.isMe,
    required this.msg,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final replyToMe = msg.reply?.userId == userId;

    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          if (!isMe)
            ProfileAvt(
              borderColor: Colors.amber,
              url: msg.profileURL,
              showBorder: isOwner,
              size: 40,
            ),
          Column(
            spacing: 4,
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                spacing: 4,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isOwner)
                    Image.asset(AppAssets.icons.crownIcon, height: 14),
                  MyText(
                    text: isMe ? "You" : msg.name.capitalize,
                    size: AppConstants.subtitle,
                    family: AppFonts.bold,
                  ),
                ],
              ),
              if (msg.reply != null)
                CustomCard(
                  margin: 0,
                  width: null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: <Widget>[
                      MyText(
                        text:
                            "Replied to ${replyToMe ? "you" : msg.reply!.name}",
                        family: AppFonts.semibold,
                        color: theme.hintColor,
                        size: 10,
                      ),
                      MyText(
                        text: msg.reply!.message,
                        color: theme.hintColor,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              MyText(text: msg.message),
              ReactionRow(userId: userId, message: msg),
            ],
          ).flexible(),
          if (isMe)
            ProfileAvt(
              borderColor: Colors.amber,
              url: msg.profileURL,
              showBorder: isOwner,
              size: 40,
            ),
        ],
      ).padOnly(l: isMe ? 30 : 0, r: isMe ? 0 : 30),
    );
  }
}
