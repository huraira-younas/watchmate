import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class BottomBuilder extends StatefulWidget {
  const BottomBuilder({super.key});

  @override
  State<BottomBuilder> createState() => _BottomBuilderState();
}

class _BottomBuilderState extends State<BottomBuilder> {
  final _controller = TextEditingController();
  final _playerBloc = getIt<PlayerBloc>();
  final _user = getIt<AuthBloc>().user!;

  void _onSubmit({PartyMessageModel? reply}) {
    final partyId = _playerBloc.partyId;
    final message = _controller.text.trim();
    if (message.isNullOrEmpty || partyId == null) return;

    _playerBloc.add(
      SendMessage(
        partyId: partyId,
        message: PartyMessageModel(
          profileURL: _user.profileURL ?? "",
          message: message,
          userId: _user.id,
          name: _user.name,
          reply: reply,
        ),
      ),
    );

    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty;
    final theme = context.theme;

    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (p, c) => p.reply != c.reply,
      builder: (context, state) {
        final reply = state.reply;
        final isMe = reply?.userId == _user.id;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.highlightColor),
            color: theme.cardColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (reply != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: <Widget>[
                    MyText(
                      text: "Replying to ${isMe ? "yourself" : reply.name}",
                      family: AppFonts.semibold,
                      color: theme.hintColor,
                      size: 10,
                    ),
                    MyText(
                      color: theme.hintColor,
                      text: reply.message,
                      size: 12,
                    ),
                  ],
                ).padOnly(l: 20, r: 20, t: 10),
              TextField(
                maxLines: 3,
                minLines: 1,
                controller: _controller,
                onChanged: (v) => setState(() {}),
                decoration: customInputDecoration(
                  border: InputBorder.none,
                  hint: "Enter message",
                  context: context,
                  filled: false,
                  prefixIcon: const Icon(Icons.text_fields_rounded),
                  suffixIcon: AnimatedContainer(
                    margin: const EdgeInsets.all(6),
                    duration: 200.millis,
                    decoration: BoxDecoration(
                      color: canSend
                          ? theme.primaryColor
                          : theme.highlightColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      size: 20,
                      color: Colors.white,
                    ),
                  ).onTap(() => _onSubmit(reply: reply)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
