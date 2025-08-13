import 'package:watchmate_app/common/services/socket_service/socket_events.dart';
import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/features/player/model/party_message_model.dart';
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
  String? partId;

  PlayerBloc(this._socket, String userId) : super(const PlayerState()) {
    on<CreateParty>(_onCreateParty);
    on<HandleParty>(_onHandleParty);
    on<JoinParty>(_onJoinParty);

    _joinNamespace(userId);
  }

  void _joinNamespace(String userId) {
    _socket.connect(query: {"userId": userId}, type: _type);
    _eventSubs[SocketEvents.video.joinParty] = _socket
        .onEvent(type: _type, event: SocketEvents.video.joinParty)
        .listen((d) => _handlePartyEvent(d, userId));

    _eventSubs[SocketEvents.video.leaveParty] = _socket
        .onEvent(type: _type, event: SocketEvents.video.leaveParty)
        .listen((d) => _handlePartyEvent(d, userId));
  }

  void _handlePartyEvent(Map<String, dynamic> data, String userId) {
    final res = data['data'];
    Logger.info(tag: _type.name, message: res.toString());

    if (res == null || res['userId'] == userId) return;
    add(HandleParty(data: res, count: res['joined'], isJoined: true));
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
  }

  void _onJoinParty(JoinParty event, Emitter<PlayerState> emit) {
    _socket.emit(_type, SocketEvents.video.joinParty, event.toJson());
  }

  void _onHandleParty(HandleParty event, Emitter<PlayerState> emit) {
    final message = PartyMessageModel.fromJson(event.data);
    final messages = [...state.messages, message];

    emit(PlayerState(joined: event.count, messages: messages));
  }
}
