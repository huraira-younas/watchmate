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
    on<CloseParty>(_onCloseParty);
    on<JoinParty>(_onJoinParty);

    on<CancelReply>(
      (ev, emit) => emit(state.copyWith(messages: state.messages, reply: null)),
    );

    _joinNamespace(userId);
  }

  Future<void> _joinNamespace(String userId) async {
    await _disposeListeners();
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

    _eventSubs[SocketEvents.video.closeParty] = _socket
        .onEvent(type: _type, event: SocketEvents.video.closeParty)
        .listen((data) => _handleCloseParty(data));

    _eventSubs[SocketEvents.video.reactMessage] = _socket
        .onEvent(type: _type, event: SocketEvents.video.reactMessage)
        .listen((data) => _handleMessage(data, isReact: true));
  }

  void _handleCloseParty(Map<String, dynamic> data) {
    final res = data['data'];
    if (res == null) return;
    final comingPartyId = res["partyId"];
    if (comingPartyId != partyId) return;

    add(const HandleParty(reset: true, count: -1, data: {}));
  }

  void _handleVideoState(Map<String, dynamic> data) {
    final res = data['data'];
    if (res == null) return;
    add(HandleParty(isVideoState: true, count: state.joined, data: res));
  }

  void _handleMessage(Map<String, dynamic> data, {bool isReact = false}) {
    final res = data['data'];
    if (res == null) return;
    add(HandleParty(count: state.joined, data: res, isReact: isReact));
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

  Future<void> _disposeListeners() async {
    _socket.disconnect(_type);
    _eventSubs.forEach((key, sub) async {
      Logger.info(tag: _type.name, message: "Released $key");
      await sub.cancel();
    });
  }

  @override
  Future<void> close() async {
    await _disposeListeners();
    return super.close();
  }

  void _onCreateParty(CreateParty event, Emitter<PlayerState> emit) {
    _socket.emit(_type, SocketEvents.video.createParty, event.toJson());
    emit(PlayerState(partyId: event.userId));
    partyId = event.userId;
  }

  void _onHandleVideoState(HandleVideoState event, Emitter<PlayerState> emit) {
    _socket.emit(_type, SocketEvents.video.videoState, event.toJson());
    partyId = event.partyId;
    emit(
      state.copyWith(
        videoState: event.videoState,
        messages: state.messages,
        reply: state.reply,
      ),
    );
  }

  void _onCloseParty(CloseParty event, Emitter<PlayerState> emit) {
    _socket.emit(_type, SocketEvents.video.closeParty, {
      "userId": event.userId,
      "partyId": partyId,
    });
  }

  void _onJoinParty(JoinParty event, Emitter<PlayerState> emit) {
    if (_socket.isConnected(_type) && event.partyId == partyId) return;
    _socket.emit(_type, SocketEvents.video.joinParty, event.toJson());
    partyId = event.partyId;
  }

  void _onPartyMessage(PartyMessage event, Emitter<PlayerState> emit) {
    final messages = state.messages;
    final msg = event.message;
    partyId = event.partyId;

    if (event is SendMessage) {
      _socket.emit(_type, SocketEvents.video.partyMessage, event.toJson());
      emit(state.copyWith(reply: null, messages: [...messages, msg]));
    } else if (event is ReplyMessage) {
      emit(state.copyWith(reply: msg, messages: messages));
    } else if (event is ReactMessage) {
      _socket.emit(_type, SocketEvents.video.reactMessage, event.toJson());
      final newMsgs = _handleReaction(msg);
      emit(state.copyWith(forceRebuild: true, reply: null, messages: newMsgs));
    }
  }

  void _onHandleParty(HandleParty event, Emitter<PlayerState> emit) {
    final videoState = state.videoState;
    final messages = state.messages;
    final reply = state.reply;
    PlayerState newState;
    if (event.isReact) {
      newState = state.copyWith(
        messages: _handleReaction(PartyMessageModel.fromJson(event.data)),
        forceRebuild: true,
        reply: reply,
      );
    } else if (event.reset) {
      partyId = null;
      newState = PlayerState(
        videoState: videoState,
        joined: event.count,
        messages: const [],
        partyId: partyId,
      );
    } else if (event.isVideoState) {
      newState = PlayerState(
        videoState: VideoState.fromJson(event.data),
        joined: event.count,
        messages: messages,
        partyId: partyId,
        reply: reply,
      );
    } else {
      newState = PlayerState(
        messages: [...messages, PartyMessageModel.fromJson(event.data)],
        videoState: videoState,
        joined: event.count,
        partyId: partyId,
        reply: reply,
      );
    }

    emit(newState);
  }

  List<PartyMessageModel> _handleReaction(PartyMessageModel message) {
    final messages = state.messages;
    final idx = messages.indexWhere((e) => e.id == message.id);
    if (idx == -1) return messages;

    messages[idx] = message;
    return messages;
  }
}
