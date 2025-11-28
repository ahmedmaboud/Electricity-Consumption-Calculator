import 'package:get/get.dart';
import 'package:graduation_project_depi/user_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final cloud = Get.find<SupabaseClient>();
  Future<bool> register(String email, String password, String name) async {
    try {
      final authResponse = await cloud.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) return false;

      // Insert into your custom profile table
      await cloud.from('user_profile').insert({
        'auth_id': authUser.id,
        'name': name,
      });

      await UserSession().loadUserInfo();

      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<bool> login(String mail, String password) async {
    try {
      final response = await cloud.auth.signInWithPassword(
        email: mail,
        password: password,
      );

      if (response.user == null) return false;

      await UserSession().loadUserInfo();

      print('User logged in: ${UserSession().currentUser?.email}');
      return true;
    } on AuthRetryableFetchException {
      rethrow;
    } catch (e) {
      print("LOGIN ERROR: $e");
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      await cloud.auth.signOut();
      UserSession().clear();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  bool isLogin() => cloud.auth.currentSession != null;
}
