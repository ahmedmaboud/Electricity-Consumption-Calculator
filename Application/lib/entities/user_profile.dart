import 'dart:convert';

UserProfile userFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  final String authId;
  final String email;
  final String name;

  UserProfile({required this.authId, required this.name, required this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    authId: json["auth_id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "auth_id": authId,
    "name": name,
    "email": email,
  };
}
