part of 'bloc.dart';

@immutable
class PlayerState {
  final List<PartyMessageModel> messages;
  final VideoState? videoState;
  final int joined;

  const PlayerState({
    this.messages = const [],
    this.joined = 1,
    this.videoState,
  });
}

final class CustomState extends BaseCustomState {
  CustomState({required super.message, required super.title});
}
