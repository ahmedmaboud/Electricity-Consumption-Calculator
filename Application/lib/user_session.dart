import 'dart:convert';

import 'package:graduation_project_depi/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  UserProfile? currentUser;

  final _supabase = Supabase.instance.client;

  Future<void> loadUserInfo() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return;

    final result = await _supabase
        .from('user_profile')
        .select('*')
        .eq('auth_id', authUser.id)
        .single();
    result['email'] = authUser.email;

    currentUser = userFromJson(json.encode(result));
  }

  void clear() {
    currentUser = null;
  }
}
