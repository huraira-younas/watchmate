part of 'bloc.dart';

@immutable
class PlayerState {
  final List<PartyMessageModel> messages;
  final PartyMessageModel? reply;
  final VideoState? videoState;
  final String? partyId;
  final int joined;

  const PlayerState({
    this.messages = const [],
    this.joined = 1,
    this.videoState,
    this.partyId,
    this.reply,
  });

  PlayerState copyWith({
    required List<PartyMessageModel> messages,
    required PartyMessageModel? reply,
  }) => PlayerState(
    videoState: videoState,
    messages: messages,
    partyId: partyId,
    joined: joined,
    reply: reply,
  );
}

final class CustomState extends BaseCustomState {
  CustomState({required super.message, required super.title});
}
