import 'package:watchmate_app/common/services/api_service/api_routes.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class VideoUser {
  final String? profileURL;
  final String name;
  final String id;

  const VideoUser({
    required this.profileURL,
    required this.name,
    required this.id,
  });

  factory VideoUser.fromJson(Map<String, dynamic> json) {
    return VideoUser(
      profileURL: json['profileURL'],
      name: json['name'] ?? '',
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'profileURL': profileURL,
    'name': name,
    'id': id,
  };

  @override
  String toString() => 'VideoUser(${toJson()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoUser &&
          runtimeType == other.runtimeType &&
          profileURL == other.profileURL &&
          name == other.name &&
          id == other.id;

  @override
  int get hashCode => profileURL.hashCode ^ name.hashCode ^ id.hashCode;

  String get fullProfileURL {
    return ApiRoutes.file.getFile(
      url: profileURL ?? AppConstants.userAvt,
      userId: id,
    );
  }
}
