import 'dart:convert';

UserProfile userFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  final String authId;
  final String email;
  final DateTime createdAt;

  UserProfile({
    required this.authId,
    required this.email,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    authId: json["auth_id"],
    email: json["email"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "auth_id": authId,
    "email": email,
    "created_at": createdAt.toIso8601String(),
  };
}
