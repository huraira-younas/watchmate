part of 'bloc.dart';

abstract class LinkEvent extends Equatable {
  const LinkEvent();

  @override
  List<Object?> get props => [];
}

class LinkTypeChanged extends LinkEvent {
  const LinkTypeChanged({required this.type});
  final VideoType type;

  @override
  List<Object?> get props => [type];
}

class LinkVisibilityChanged extends LinkEvent {
  const LinkVisibilityChanged({required this.visibility});
  final VideoVisibility visibility;

  @override
  List<Object?> get props => [visibility];
}

class LinkSubmitted extends LinkEvent {
  const LinkSubmitted({required this.url, this.title, this.thumbnail});
  final String? thumbnail;
  final String? title;
  final String url;

  @override
  List<Object?> get props => [url, title, thumbnail];
}

class LinkSocketDataReceived extends LinkEvent {
  const LinkSocketDataReceived({required this.type, required this.data});
  final Map<String, dynamic> data;
  final String type;

  @override
  List<Object?> get props => [type, data];
}
