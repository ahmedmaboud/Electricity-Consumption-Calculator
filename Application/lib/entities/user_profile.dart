import 'dart:convert';

UserProfile userFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  final String authId;
  final String email;
  final String name;
  String avatar;
  int? budgetLimit;

  UserProfile({
    required this.authId,
    required this.name,
    required this.email,
    required this.avatar,
    this.budgetLimit,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    authId: json["auth_id"],
    name: json["name"],
    email: json["email"],
    avatar: json["avatar"],
    budgetLimit: (json["budget_limit"] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    "auth_id": authId,
    "name": name,
    "email": email,
    "budget_limit": budgetLimit,
    "avatar": avatar,
  };
}
