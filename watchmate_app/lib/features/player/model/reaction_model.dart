import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';

@immutable
class Reaction extends Equatable {
  final String profileURL;
  final String userId;
  final String react;
  final String name;

  const Reaction({
    required this.profileURL,
    required this.userId,
    required this.react,
    required this.name,
  });

  Reaction copyWith({
    String? profileURL,
    String? userId,
    String? react,
    String? name,
  }) {
    return Reaction(
      profileURL: profileURL ?? this.profileURL,
      userId: userId ?? this.userId,
      react: react ?? this.react,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() => {
    'profileURL': profileURL,
    'userId': userId,
    'react': react,
    'name': name,
  };

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      profileURL: json['profileURL'] as String,
      userId: json['userId'] as String,
      react: json['react'] as String,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [profileURL, userId, react, name];

  @override
  String toString() {
    return 'Reaction(userId: $userId, react: $react, name: $name, profileURL: $profileURL)';
  }
}
