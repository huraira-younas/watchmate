import 'package:go_router/go_router.dart';
import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/features/player/model/reaction_model.dart';
import 'package:watchmate_app/common/widgets/profile_avt.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/player/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

class ReactionRow extends StatelessWidget {
  final PartyMessageModel message;
  final bool isBottomSheet;
  final String userId;

  const ReactionRow({
    this.isBottomSheet = false,
    required this.message,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reactions = message.reactions;

    final grouped = <String, Set<Reaction>>{};
    for (final r in reactions) {
      grouped.putIfAbsent(r.react, () => <Reaction>{});
      grouped[r.react]!.add(r);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: grouped.entries.map((entry) {
        final emoji = entry.key;
        final users = entry.value;
        final isMine = users.any((r) => r.userId == userId);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isMine
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : null,
            border: Border.all(
              color: isMine ? theme.colorScheme.primary : theme.highlightColor,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MyText(
                color: isMine ? theme.colorScheme.primary : null,
                text: emoji,
                size: 13,
              ),
              const SizedBox(width: 3),
              MyText(
                color: isMine ? theme.colorScheme.primary : null,
                text: users.length.toString(),
                family: AppFonts.bold,
                size: 11,
              ),
            ],
          ),
        ).onGesture(
          onTap: !isBottomSheet
              ? () => _showReactionSheet(context: context, message: message)
              : () {
                  if (!isMine) return;
                  final updated = [
                    for (final r in message.reactions)
                      if (r.userId != userId || r.react != emoji) r,
                  ];

                  getIt<PlayerBloc>().add(
                    ReactMessage(
                      message: message.copyWith(reactions: updated),
                      partyId: getIt<PlayerBloc>().partyId ?? "",
                    ),
                  );

                  context.pop();
                },
        );
      }).toList(),
    );
  }

  void _showReactionSheet({
    required PartyMessageModel message,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final reactions = message.reactions;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) {
        return Material(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          color: theme.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              14.h,
              MyText(
                text:
                    "${reactions.length} reaction${reactions.length > 1 ? "s" : ""}",
                size: AppConstants.title,
                family: AppFonts.bold,
              ).padSym(h: 20, v: 10),
              14.h,
              ReactionRow(
                isBottomSheet: true,
                message: message,
                userId: userId,
              ).padSym(h: 20),
              10.h,
              ListView.builder(
                shrinkWrap: true,
                itemCount: reactions.length,
                itemBuilder: (_, idx) {
                  final r = reactions[idx];
                  return ListTile(
                    leading: ProfileAvt(size: 40, url: r.profileURL),
                    trailing: MyText(text: r.react, size: 18),
                    title: MyText(
                      text: userId == r.userId ? "You" : r.name,
                      family: AppFonts.semibold,
                      size: 14,
                    ),
                  );
                },
              ).flexible(),
            ],
          ),
        ).padAll(6);
      },
    );
  }
}
