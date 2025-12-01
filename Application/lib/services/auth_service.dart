import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../user_session.dart';

class AuthService {
  final cloud = Get.find<SupabaseClient>();

  AuthService() {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    cloud.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        Get.toNamed('/update_password');
      } else if (event == AuthChangeEvent.signedIn) {
        UserSession().loadUserInfo();
        Get.offAllNamed('/calculator_page');
      }
    });
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      final authResponse = await cloud.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.flutter://login-callback',
      );

      final authUser = authResponse.user;
      if (authUser == null) return false;

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
      return true;
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

  Future<void> sendPasswordResetEmail(String email) async {
    await cloud.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-callback',
    );
  }

  Future<void> updateUserPassword(String newPassword) async {
    await cloud.auth.updateUser(UserAttributes(password: newPassword));
  }

  bool isLogin() => cloud.auth.currentSession != null;
}
