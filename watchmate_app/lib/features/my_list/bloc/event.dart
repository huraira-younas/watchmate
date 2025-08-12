part of 'bloc.dart';

@immutable
abstract class ListEvent {
  final Function(CustomState error)? onError;
  final Function()? onSuccess;

  const ListEvent({required this.onSuccess, required this.onError});
}

class FetchVideos extends ListEvent {
  final ListType type;
  final String userId;
  final bool refresh;

  const FetchVideos({
    this.refresh = false,
    required this.userId,
    required this.type,
    super.onSuccess,
    super.onError,
  });
}

class DeleteVideo extends ListEvent {
  final ListType type;
  final String userId;
  final String id;

  const DeleteVideo({
    required this.userId,
    required this.type,
    required this.id,
    super.onSuccess,
    super.onError,
  });
}
