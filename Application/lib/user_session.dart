import 'dart:convert';
import 'dart:io';
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

    try {
      final result = await _supabase
          .from('user_profile')
          .select('*')
          .eq('auth_id', authUser.id)
          .single();

      result['email'] = authUser.email;
      currentUser = userFromJson(json.encode(result));
    } on AuthRetryableFetchException catch (e) {
      print("LOAD USER INFO OFFLINE: $e");
      return;
    } on SocketException catch (e) {
      print("LOAD USER INFO SOCKET OFFLINE: $e");
      return;
    } catch (e) {
      print("LOAD USER INFO ERROR: $e");
      return;
    }
  }

  void clear() {
    currentUser = null;
  }
}
