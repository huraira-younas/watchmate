import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/extensions/exports.dart';
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

  void _onSubmit() {
    final partyId = _playerBloc.partyId;
    final message = _controller.text.trim();
    if (message.isNullOrEmpty || partyId == null) return;

    _playerBloc.add(
      PartyMessage(
        partyId: partyId,
        message: PartyMessageModel(
          profileURL: _user.profileURL ?? "",
          message: message,
          userId: _user.id,
          name: _user.name,
        ),
      ),
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty;
    final theme = context.theme;

    return CustomTextField(
      prefixIcon: const Icon(Icons.title),
      onChange: (v) => setState(() {}),
      controller: _controller,
      hint: "Enter message",
      maxLines: 3,
      minLines: 1,
      suffixIcon: AnimatedContainer(
        margin: const EdgeInsets.all(6),
        duration: 200.millis,
        decoration: BoxDecoration(
          color: canSend ? theme.primaryColor : theme.highlightColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send, size: 20, color: Colors.white),
      ).onTap(_onSubmit),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
