import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../user_session.dart';
import 'dart:io';

class AuthService {
  final cloud = Get.find<SupabaseClient>();

  AuthService() {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    cloud.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        Get.toNamed('/update_password');
      } else if (event == AuthChangeEvent.signedIn) {
        try {
          await UserSession().loadUserInfo();
        } catch (e) {
          print("Signed in, but loadUserInfo failed: $e");
        }

        Get.offAllNamed('/main_shell');
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
    } on AuthRetryableFetchException {
      rethrow;
    } on SocketException {
      rethrow;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await cloud.auth.signInWithPassword(email: email, password: password);

      try {
        await UserSession().loadUserInfo();
      } catch (e) {
        print("Profile load failed after login: $e");
      }

      return true;
    } on AuthRetryableFetchException {
      rethrow;
    } on SocketException {
      rethrow;
    } on AuthApiException {
      rethrow;
    } catch (e) {
      print("Login error: $e");
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

  Future<bool> deleteAccount() async {
    try {
      await cloud.rpc('delete_user');
      await logout();
      return true;
    } catch (e) {
      print("Delete Account Error: $e");
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
