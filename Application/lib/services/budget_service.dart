import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetService {
  final _supabase = Get.find<SupabaseClient>();

  /// Updates the budget limit for the currently authenticated user.
  Future<bool> updateBudgetLimit(int newLimit) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase
          .from('user_profile')
          .update({'budget_limit': newLimit})
          .eq('auth_id', userId);
      return true;
    } catch (e) {
      print("BudgetService Error (update): $e");
      return false;
    }
  }
}
