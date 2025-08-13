part of 'bloc.dart';

@immutable
sealed class PlayerEvent {
  final Function(CustomState error)? onError;
  final Function()? onSuccess;

  const PlayerEvent({required this.onSuccess, required this.onError});
}

class CreateParty extends PlayerEvent {
  final String userId;
  const CreateParty({required this.userId, super.onSuccess, super.onError});

  Map<String, String> toJson() => {"userId": userId, "partyId": userId};
}

class JoinParty extends PlayerEvent {
  final String partyId;
  final String userId;

  const JoinParty({
    required this.userId,
    required this.partyId,
    super.onSuccess,
    super.onError,
  });

  Map<String, String> toJson() => {"userId": userId, "partyId": partyId};
}
