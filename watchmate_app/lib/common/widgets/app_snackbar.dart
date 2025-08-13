import 'package:watchmate_app/extensions/context_extensions.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
final Queue<String> _snackQueue = Queue();
String? _lastMessage;
bool _isShowing = false;

void showAppSnackBar(String message) {
  if (_snackQueue.isNotEmpty && _snackQueue.last == message) {
    return;
  }

  if (_isShowing && _snackQueue.isEmpty && _lastMessage == message) {
    return;
  }

  _snackQueue.add(message);

  if (scaffoldKey.currentState == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processQueue();
    });
  } else {
    _processQueue();
  }
}

void _processQueue() {
  if (_isShowing || _snackQueue.isEmpty) return;

  final message = _snackQueue.removeFirst();
  _lastMessage = message;
  _isShowing = true;

  final snackBar = SnackBar(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: scaffoldKey.currentContext?.theme.cardColor,
    content: MyText(text: message, family: AppFonts.medium),
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(12),
  );

  if (scaffoldKey.currentState == null) return;
  scaffoldKey.currentState?.showSnackBar(snackBar).closed.then((_) {
    _isShowing = false;
    _processQueue();
  });
}
