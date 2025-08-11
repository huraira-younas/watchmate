import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/common/services/socket_service/socket_events.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'events.dart';
part 'states.dart';

class LinkBloc extends Bloc<LinkEvent, LinkState> {
  final SocketNamespaceService socket;
  final AuthBloc authBloc;

  LinkBloc({required this.socket, required this.authBloc}) : super(const LinkState()) {
    on<LinkVisibilityChanged>((e, emit) => emit(state.copyWith(visibility: e.visibility)));
    on<LinkTypeChanged>((e, emit) => emit(state.copyWith(type: e.type)));
    on<LinkSocketDataReceived>(_onSocketDataReceived);
    on<LinkSubmitted>(_onLinkSubmitted);

    final socketMap = {
      VideoType.direct.name: SocketEvents.stream.downloadDirect,
      VideoType.youtube.name: SocketEvents.stream.downloadYT,
    };

    socketMap.forEach((type, event) {
      socket.onEvent(event: event, type: NamespaceType.stream).listen(
            (data) => add(LinkSocketDataReceived(type: type, data: data)),
          );
    });
  }

  void _onLinkSubmitted(LinkSubmitted event, Emitter<LinkState> emit) {
    _updateProcess(emit, LinkStatus.loading);

    final eventMap = {
      VideoType.direct.name: SocketEvents.stream.downloadDirect,
      VideoType.youtube.name: SocketEvents.stream.downloadYT,
    };

    socket.emit(NamespaceType.stream, eventMap[state.type.name]!, {
      if (state.type == VideoType.direct) ...{
        "thumbnail": event.thumbnail,
        "title": event.title,
      },
      "visibility": state.visibility.name,
      "userId": authBloc.user?.id,
      "type": state.type.name,
      "url": event.url,
    });
  }

  void _onSocketDataReceived(
    LinkSocketDataReceived event,
    Emitter<LinkState> emit,
  ) {
    final json = event.data;
    final code = json['code'];

    final process = switch (code) {
      201 => DownloadProcess(
        status: LinkStatus.downloading,
        downloadingVideo: DownloadingVideo.fromJson(
          Map<String, dynamic>.from(json['data']),
        ),
      ),
      200 => DownloadProcess(
        status: LinkStatus.success,
        downloadedVideo: DownloadedVideo.fromJson(
          Map<String, dynamic>.from(json['data']),
        ),
      ),
      _ => DownloadProcess(
        error: json["error"] ?? json["message"] ?? "Unknown error",
        status: LinkStatus.error,
      ),
    };

    _emitForType(emit, process, event.type);
  }

  void _updateProcess(Emitter<LinkState> emit, LinkStatus status) {
    final process = DownloadProcess(status: status);
    _emitForType(emit, process, state.type.name);
  }

  void _emitForType(
    Emitter<LinkState> emit,
    DownloadProcess process,
    String type,
  ) {
    emit(
      type == VideoType.direct.name
          ? state.copyWith(direct: process)
          : state.copyWith(yt: process),
    );
  }
}
