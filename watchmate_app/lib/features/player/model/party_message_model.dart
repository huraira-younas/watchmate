import 'package:watchmate_app/features/player/model/reaction_model.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';

@immutable
class PartyMessageModel extends Equatable {
  final PartyMessageModel? reply;
  final List<Reaction> reactions;
  final String profileURL;
  final String message;
  final String userId;
  final String name;
  final String id;

  const PartyMessageModel({
    this.reactions = const [],
    required this.profileURL,
    required this.message,
    required this.userId,
    required this.name,
    required this.id,
    this.reply,
  });

  PartyMessageModel copyWith({
    List<Reaction>? reactions,
    bool setReplyNull = false,
    PartyMessageModel? reply,
    String? profileURL,
    String? message,
    String? userId,
    String? name,
    String? id,
  }) {
    return PartyMessageModel(
      reply: setReplyNull ? null : (reply ?? this.reply),
      profileURL: profileURL ?? this.profileURL,
      reactions: reactions ?? this.reactions,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    profileURL,
    reactions,
    message,
    userId,
    reply,
    name,
    id,
  ];

  bool equalTo(PartyMessageModel other) => this == other;

  Map<String, dynamic> toJson() => {
    'reactions': reactions.map((e) => e.toJson()).toList(),
    'reply': reply?.toJson(),
    'profileURL': profileURL,
    'message': message,
    'userId': userId,
    'name': name,
    'id': id,
  };

  factory PartyMessageModel.fromJson(Map<String, dynamic> json) {
    return PartyMessageModel(
      reactions: (json['reactions'] as List<dynamic>? ?? [])
          .map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      reply: (json['reply'] is Map<String, dynamic>)
          ? PartyMessageModel.fromJson(json['reply'] as Map<String, dynamic>)
          : null,
      profileURL: json['profileURL'] as String,
      message: json['message'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      id: json['id'] as String,
    );
  }

  @override
  String toString() {
    return 'PartyMessageModel(id: $id, reactions: $reactions, profileURL: $profileURL, message: $message, name: $name, userId: $userId, reply: ${reply != null})';
  }
}
