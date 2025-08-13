import 'dart:async';

import 'package:watchmate_app/common/services/socket_service/socket_events.dart';
import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/features/player/model/party_message_model.dart';
import 'package:watchmate_app/common/models/custom_state_model.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/utils/logger.dart';

part 'event.dart';
part 'state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final _eventSubs = <String, StreamSubscription>{};
  final SocketNamespaceService _socket;
  final _type = NamespaceType.video;
  String? partId;

  PlayerBloc(this._socket, String userId) : super(const PlayerState()) {
    on<CreateParty>(_onCreateParty);
    on<JoinParty>(_onJoinParty);

    _joinNamespace(userId);
  }

  void _joinNamespace(String userId) {
    _socket.connect(query: {"userId": userId}, type: _type);
    _eventSubs[SocketEvents.video.joinParty] = _socket
        .onEvent(type: _type, event: SocketEvents.video.joinParty)
        .listen((data) {
          Logger.info(tag: _type.name, message: data.toString());
        });
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

  Future<void> _onCreateParty(
    CreateParty event,
    Emitter<PlayerState> emit,
  ) async {
    _socket.emit(_type, SocketEvents.video.createParty, event.toJson());
  }

  Future<void> _onJoinParty(JoinParty event, Emitter<PlayerState> emit) async {
    _socket.emit(_type, SocketEvents.video.joinParty, event.toJson());
  }
}
