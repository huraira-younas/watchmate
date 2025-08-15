part of 'bloc.dart';

@immutable
sealed class PlayerEvent {
  final Function(CustomState error)? onError;
  final Function()? onSuccess;

  const PlayerEvent({required this.onSuccess, required this.onError});
}

class CreateParty extends PlayerEvent {
  const CreateParty({required this.userId, super.onSuccess, super.onError});
  final String userId;

  Map<String, String> toJson() => {"userId": userId, "partyId": userId};
}

class CloseParty extends PlayerEvent {
  final String partyId;
  final String userId;

  const CloseParty({
    required this.partyId,
    required this.userId,
    super.onSuccess,
    super.onError,
  });

  Map<String, String> toJson() => {"userId": userId, "partyId": partyId};
}

class HandleParty extends PlayerEvent {
  final Map<String, dynamic> data;
  final bool isVideoState;
  final bool isJoined;
  final bool reset;
  final int count;

  const HandleParty({
    this.isVideoState = false,
    this.isJoined = true,
    required this.count,
    this.reset = false,
    required this.data,
    super.onSuccess,
    super.onError,
  });
}

class JoinParty extends PlayerEvent {
  final String partyId;
  final String userId;

  const JoinParty({
    required this.partyId,
    required this.userId,
    super.onSuccess,
    super.onError,
  });

  Map<String, String> toJson() => {"userId": userId, "partyId": partyId};
}

abstract class PartyMessage extends PlayerEvent {
  final PartyMessageModel message;
  final String partyId;

  const PartyMessage({
    required this.message,
    required this.partyId,
    super.onSuccess,
    super.onError,
  });

  Map<String, dynamic> toJson() => {
    "message": message.toJson(),
    "partyId": partyId,
  };
}

class SendMessage extends PartyMessage {
  const SendMessage({required super.message, required super.partyId});
}

class ReplyMessage extends PartyMessage {
  const ReplyMessage({required super.message, required super.partyId});
}

class HandleVideoState extends PlayerEvent {
  final VideoState videoState;
  final String partyId;

  const HandleVideoState({
    required this.videoState,
    required this.partyId,
    super.onSuccess,
    super.onError,
  });

  Map<String, dynamic> toJson() => {
    "videoState": videoState.toJson(),
    "partyId": partyId,
  };
}
