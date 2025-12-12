import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Get.find<SupabaseClient>();

  Future<bool> updateAvatar(String userId, String avatarFilename) async {
    try {
      await _supabase
          .from('user_profile')
          .update({'avatar': avatarFilename})
          .eq('auth_id', userId);
      return true;
    } catch (e) {
      print('ProfileService Error: $e');
      return false;
    }
  }
}
