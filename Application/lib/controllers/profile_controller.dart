import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/entities/user_profile.dart';
import 'package:graduation_project_depi/services/auth_service.dart';
import 'package:graduation_project_depi/user_session.dart';

class ProfileController extends GetxController {
  final pushNotifications = true.obs;
  final darkMode = false.obs;

  late UserProfile? currentUser;

  @override
  void onInit() {
    super.onInit();
    currentUser = UserSession().currentUser;
  }

  void toggleNotifications(bool value) {
    pushNotifications.value = value;
  }

  void toggleDarkMode(bool value) {
    darkMode.value = value;
    // Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
  }

  void saveSettings() {
    // actual save logic here
    Get.snackbar(
      "Saved".tr,
      "Profile settings saved locally".tr,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    final service = Get.find<AuthService>();
    service.logout();
    UserSession().clear(); // Clear local session data
    Get.offAllNamed('/login');
    Get.snackbar(
      "Logged Out".tr,
      "You have been logged out successfully!".tr,
      backgroundColor: Colors.blue.shade400,
      colorText: Colors.white,
    );
  }

  void deleteAccount() {
    // Add delete account logic confirmation dialog here
    Get.defaultDialog(
      title: "Delete Account".tr,
      middleText:
          "Are you sure you want to delete your account? This cannot be undone.".tr,
      textConfirm: "Delete".tr,
      textCancel: "Cancel".tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Call delete API
        Get.back();
      },
    );
  }
}
