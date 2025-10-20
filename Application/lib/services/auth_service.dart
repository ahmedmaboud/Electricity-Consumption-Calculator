import 'package:graduation_project_depi/main.dart';
import 'package:graduation_project_depi/user_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<bool> register(String email, String password) async {
    try {
      final authResponse = await cloud.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) return false;
      await UserSession().loadUserInfo();

      return true;
    } on AuthRetryableFetchException {
      rethrow;
    } catch (e) {
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
      return false;
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
