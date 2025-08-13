import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';

@immutable
class PartyMessageModel extends Equatable {
  final PartyMessageModel? reply;
  final String profileURL;
  final String message;
  final String userId;
  final String name;

  const PartyMessageModel({
    required this.profileURL,
    required this.message,
    required this.userId,
    required this.reply,
    required this.name,
  });

  PartyMessageModel copyWith({
    bool setReplyNull = false,
    PartyMessageModel? reply,
    String? profileURL,
    String? message,
    String? userId,
    String? name,
  }) {
    return PartyMessageModel(
      reply: setReplyNull ? null : (reply ?? this.reply),
      profileURL: profileURL ?? this.profileURL,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [reply, profileURL, message, name, userId];
  bool equalTo(PartyMessageModel other) => this == other;

  Map<String, dynamic> toJson() => {
    'reply': reply?.toJson(),
    'profileURL': profileURL,
    'message': message,
    'userId': userId,
    'name': name,
  };

  factory PartyMessageModel.fromJson(Map<String, dynamic> json) {
    return PartyMessageModel(
      reply: (json['reply'] is Map<String, dynamic>)
          ? PartyMessageModel.fromJson(json['reply'] as Map<String, dynamic>)
          : null,
      profileURL: json['profileURL'] as String,
      message: json['message'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() {
    return 'PartyMessageModel(profileURL: $profileURL, message: $message, name: $name, userId: $userId, reply: ${reply != null})';
  }
}
