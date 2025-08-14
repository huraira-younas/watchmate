import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/common/services/socket_service/socket_events.dart';
import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/features/player/model/video_state_model.dart';
import 'package:watchmate_app/common/models/custom_state_model.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:watchmate_app/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async' show StreamSubscription;

part 'event.dart';
part 'state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final _eventSubs = <String, StreamSubscription>{};
  final SocketNamespaceService _socket;
  final _type = NamespaceType.video;
  String? partyId;

  PlayerBloc(this._socket, String userId) : super(const PlayerState()) {
    on<HandleVideoState>(_onHandleVideoState);
    on<PartyMessage>(_onPartyMessage);
    on<CreateParty>(_onCreateParty);
    on<HandleParty>(_onHandleParty);
    on<JoinParty>(_onJoinParty);

    _joinNamespace(userId);
  }

  void _joinNamespace(String userId) {
    _socket.connect(
      onReconnect: () => _handleReconnect(userId),
      query: {"userId": userId},
      type: _type,
    );

    _eventSubs[SocketEvents.video.joinParty] = _socket
        .onEvent(type: _type, event: SocketEvents.video.joinParty)
        .listen((d) => _handlePartyEvent(d, userId));

    _eventSubs[SocketEvents.video.leaveParty] = _socket
        .onEvent(type: _type, event: SocketEvents.video.leaveParty)
        .listen((d) => _handlePartyEvent(d, userId));

    _eventSubs[SocketEvents.video.partyMessage] = _socket
        .onEvent(type: _type, event: SocketEvents.video.partyMessage)
        .listen((data) => _handleMessage(data));

    _eventSubs[SocketEvents.video.videoState] = _socket
        .onEvent(type: _type, event: SocketEvents.video.videoState)
        .listen((data) => _handleVideoState(data));
  }

  void _handleVideoState(Map<String, dynamic> data) {
    final res = data['data'];
    if (res == null) return;
    add(HandleParty(isVideoState: true, count: state.joined, data: res));
  }

  void _handleMessage(Map<String, dynamic> data) {
    final res = data['data'];
    if (res == null) return;
    add(HandleParty(count: state.joined, data: res));
  }

  void _handleReconnect(String userId) {
    Logger.info(tag: _type.name, message: "Rejoining party $partyId");
    if (partyId == null) return;

    Logger.info(tag: _type.name, message: "Rejoined party");
    add(JoinParty(userId: userId, partyId: partyId!));
  }

  void _handlePartyEvent(Map<String, dynamic> data, String userId) {
    Logger.info(tag: _type.name, message: data.toString());
    if (data['code'] != 200) {
      add(const HandleParty(count: -1, data: {}, reset: true));
      return;
    }

    final res = data['data'];
    if (res == null) return;
    add(HandleParty(count: res['joined'], data: res));
  }

  @override
  Future<void> close() async {
    _socket.disconnect(_type);
    for (final sub in _eventSubs.values) {
      await sub.cancel();
    }
    Logger.info(tag: _type.name, message: "Released Listeners");
    return super.close();
  }

  void _onCreateParty(CreateParty event, Emitter<PlayerState> emit) {
    _socket.emit(_type, SocketEvents.video.createParty, event.toJson());
    partyId = event.userId;
  }

  void _onHandleVideoState(HandleVideoState event, Emitter<PlayerState> emit) {
    _socket.emit(_type, SocketEvents.video.videoState, event.toJson());
    partyId = event.partyId;
  }

  void _onJoinParty(JoinParty event, Emitter<PlayerState> emit) {
    _socket.emit(_type, SocketEvents.video.joinParty, event.toJson());
    partyId = event.partyId;
  }

  void _onPartyMessage(PartyMessage event, Emitter<PlayerState> emit) {
    _socket.emit(_type, SocketEvents.video.partyMessage, event.toJson());
    partyId = event.partyId;
  }

  void _onHandleParty(HandleParty event, Emitter<PlayerState> emit) {
    final videoState = state.videoState;
    final messages = state.messages;
    PlayerState newState;

    if (event.reset) {
      newState = PlayerState(
        videoState: videoState,
        joined: event.count,
        messages: const [],
      );
    } else if (event.isVideoState) {
      newState = PlayerState(
        videoState: VideoState.fromJson(event.data),
        joined: event.count,
        messages: messages,
      );
    } else {
      newState = PlayerState(
        messages: [...messages, PartyMessageModel.fromJson(event.data)],
        videoState: videoState,
        joined: event.count,
      );
    }

    emit(newState);
  }
}
