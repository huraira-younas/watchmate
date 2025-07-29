import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String? profileURL;
  final String? coverURL;
  final String username;
  final String? gender;
  final bool disabled;
  final String email;
  final String? bio;
  final String name;
  final String id;

  const UserModel({
    required this.username,
    this.disabled = false,
    required this.email,
    required this.name,
    required this.id,
    this.profileURL,
    this.coverURL,
    this.gender,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    disabled: json['disabled'] == 1,
    profileURL: json['profileURL'],
    username: json['username'],
    coverURL: json['coverURL'],
    gender: json['gender'],
    email: json['email'],
    name: json['name'],
    bio: json['bio'],
    id: json['id'],
  );

  Map<String, dynamic> toJson() => {
    'profileURL': profileURL,
    'username': username,
    'disabled': disabled,
    'coverURL': coverURL,
    'gender': gender,
    'email': email,
    'name': name,
    'bio': bio,
    'id': id,
  };

  UserModel copyWith({
    String? profileURL,
    String? username,
    String? coverURL,
    String? gender,
    bool? disabled,
    String? email,
    String? name,
    String? bio,
    String? id,
  }) {
    return UserModel(
      profileURL: profileURL ?? this.profileURL,
      username: username ?? this.username,
      disabled: disabled ?? this.disabled,
      coverURL: coverURL ?? this.coverURL,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    profileURL,
    username,
    disabled,
    coverURL,
    gender,
    email,
    name,
    bio,
    id,
  ];

  @override
  String toString() =>
      'UserModel(id: $id, username: $username, name: $name, email: $email, disabled: $disabled)';
}
