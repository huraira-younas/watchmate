import 'package:watchmate_app/common/widgets/app_snackbar.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'package:watchmate_app/utils/network_utils.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'dart:async' show Timer;

enum NamespaceType { stream, notifications, chat, auth }

class SocketNamespaceService {
  final _eventStreams =
      <NamespaceType, BehaviorSubject<Map<String, dynamic>>>{};
  final _emitQueue = <NamespaceType, List<_EmitQueueItem>>{};
  final _pingWatchers = <NamespaceType, Timer>{};
  final _sockets = <NamespaceType, io.Socket>{};

  void connect({
    Duration reconnectDelay = const Duration(seconds: 3),
    Duration pingInterval = const Duration(seconds: 15),
    required Map<String, dynamic> query,
    required NamespaceType type,
  }) {
    if (_sockets.containsKey(type)) return;

    final namespace = _ns(type);
    final url = '${NetworkUtils.baseUrl}/$namespace';

    final socket = io.io(url, {
      'reconnectionDelay': reconnectDelay.inMilliseconds,
      'transports': ['websocket'],
      'path': '/v1/socket',
      'autoConnect': false,
      'reconnection': true,
      'query': query,
    });

    _eventStreams[type] = BehaviorSubject();
    _sockets[type] = socket;

    socket
      ..connect()
      ..onConnect((_) {
        Logger.info(tag: 'SOCKET:$namespace', message: 'Connected');
        if (kDebugMode) showAppSnackBar("Socket connected");
        _flush(type);
        _startPing(type, pingInterval);
      })
      ..onDisconnect((_) {
        Logger.warn(tag: 'SOCKET:$namespace', message: 'Disconnected');
        if (kDebugMode) showAppSnackBar("Socket disconnected");

        _stopPing(type);
      })
      ..onReconnect((_) {
        Logger.info(tag: 'SOCKET:$namespace', message: 'Reconnected');
      })
      ..onError((err) {
        Logger.error(tag: 'SOCKET:$namespace', message: 'Error: $err');
      })
      ..onAny((event, data) {
        Logger.debug(tag: 'SOCKET:$namespace', message: '$event → $data');
        _eventStreams[type]?.add({'event': event, 'data': data});
      });
  }

  Stream<dynamic> onEvent({
    required NamespaceType type,
    required String event,
  }) {
    return _eventStreams[type]!
        .where((e) => e['event'] == event)
        .map((e) => e['data']);
  }

  void emit(NamespaceType type, String event, [dynamic data]) {
    final socket = _sockets[type];
    if (socket?.connected == true) {
      socket!.emit(event, data);
    } else {
      _emitQueue.putIfAbsent(type, () => []).add(_EmitQueueItem(event, data));
      Logger.info(tag: '[SOCKET:${_ns(type)}]', message: 'Queued → $event');
    }
  }

  void disconnect(NamespaceType type) {
    _eventStreams.remove(type)?.close();
    _emitQueue.remove(type);
    _stopPing(type);

    _sockets.remove(type)
      ?..disconnect()
      ..dispose();
  }

  void disposeAll() {
    for (final type in _sockets.keys.toList()) {
      disconnect(type);
    }
  }

  bool isConnected(NamespaceType type) => _sockets[type]?.connected ?? false;

  void _flush(NamespaceType type) {
    final queue = _emitQueue[type];
    final socket = _sockets[type];

    if (socket?.connected != true || queue == null) return;
    for (final item in queue) {
      socket!.emit(item.event, item.data);
    }
    queue.clear();
  }

  void _startPing(NamespaceType type, Duration interval) {
    _stopPing(type);
    _pingWatchers[type] = Timer.periodic(interval, (_) {
      emit(type, 'ping', DateTime.now().toIso8601String());
    });
  }

  void _stopPing(NamespaceType type) {
    _pingWatchers.remove(type)?.cancel();
  }

  String _ns(NamespaceType type) {
    return type.name;
  }
}

class _EmitQueueItem {
  final String event;
  final dynamic data;
  _EmitQueueItem(this.event, this.data);
}
