import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String? profileURL;
  final String? fullName;
  final String? coverURL;
  final String username;
  final String? gender;
  final bool disabled;
  final String email;
  final String? bio;
  final String id;

  const UserModel({
    required this.username,
    this.disabled = false,
    required this.email,
    required this.id,
    this.profileURL,
    this.fullName,
    this.coverURL,
    this.gender,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    disabled: json['disabled'] ?? false,
    profileURL: json['profileURL'],
    username: json['username'],
    fullName: json['fullName'],
    coverURL: json['coverURL'],
    gender: json['gender'],
    email: json['email'],
    bio: json['bio'],
    id: json['id'],
  );

  Map<String, dynamic> toJson() => {
    'profileURL': profileURL,
    'username': username,
    'fullName': fullName,
    'disabled': disabled,
    'coverURL': coverURL,
    'gender': gender,
    'email': email,
    'bio': bio,
    'id': id,
  };

  UserModel copyWith({
    String? profileURL,
    String? fullName,
    String? username,
    String? coverURL,
    String? gender,
    bool? disabled,
    String? email,
    String? bio,
    String? id,
  }) {
    return UserModel(
      profileURL: profileURL ?? this.profileURL,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      disabled: disabled ?? this.disabled,
      coverURL: coverURL ?? this.coverURL,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    profileURL,
    username,
    fullName,
    disabled,
    coverURL,
    gender,
    email,
    bio,
    id,
  ];

  @override
  String toString() =>
      'UserModel(id: $id, username: $username, email: $email, disabled: $disabled)';
}
