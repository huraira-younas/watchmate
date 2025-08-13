import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/common/widgets/custom_label_widget.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/common/widgets/profile_avt.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/utils/share_service.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class BodyBuilder extends StatefulWidget {
  const BodyBuilder({
    required this.messages,
    required this.partyId,
    required this.joined,
    super.key,
  });

  final List<PartyMessageModel> messages;
  final String? partyId;
  final int joined;

  @override
  State<BodyBuilder> createState() => _BodyBuilderState();
}

class _BodyBuilderState extends State<BodyBuilder> {
  late final _playerBloc = context.read<PlayerBloc>();
  final _userId = getIt<AuthBloc>().user!.id;

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    final theme = context.theme;

    if (widget.joined == 1 && messages.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          30.h,
          const CustomLabelWidget(
            text: "Share link with your friends to watch together",
            title: "Watch with friends",
            icon: Icons.signpost,
            iconSize: 50,
          ),
          TextButton(
            onPressed: _createParty,
            style: TextButton.styleFrom(backgroundColor: theme.cardColor),
            child: const MyText(text: "Share Watch Party"),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 25),
      separatorBuilder: (_, _) => 12.h,
      itemCount: messages.length,
      itemBuilder: (_, idx) {
        final msg = messages[idx];
        return Align(
          alignment: Alignment.topLeft,
          child: Row(
            spacing: 8,
            children: <Widget>[
              ProfileAvt(size: 40, url: msg.profileURL),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(
                    size: AppConstants.subtitle,
                    text: msg.name.capitalize,
                    family: AppFonts.bold,
                  ),
                  MyText(text: msg.message),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createParty() async {
    _playerBloc.add(CreateParty(userId: _userId));
    ShareService.sharePartyLink(_userId, _userId);
  }

  @override
  void initState() {
    super.initState();
    if (widget.partyId != null) {
      _playerBloc.add(JoinParty(partyId: widget.partyId!, userId: _userId));
    }
  }
}
