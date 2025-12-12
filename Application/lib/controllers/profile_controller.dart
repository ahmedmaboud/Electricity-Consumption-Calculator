import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/entities/user_profile.dart';
import 'package:graduation_project_depi/services/auth_service.dart';
import 'package:graduation_project_depi/services/profile_service.dart'; // Import Service
import 'package:graduation_project_depi/user_session.dart';
import 'package:graduation_project_depi/controllers/theme_controller.dart';

class ProfileController extends GetxController {
  final _profileService = ProfileService(); // Use the service
  ThemeController get themeController => Get.find<ThemeController>();

  final pushNotifications = true.obs;

    bool get darkMode => themeController.isDarkMode.value;

  

  late UserProfile? currentUser;

  final tempAvatar = 'avatar1.png'.obs;

  final List<String> avatarFilenames = [
    'avatar1.png',
    'avatar2.png',
    'avatar3.png',
    'avatar4.png',
    'avatar5.png',
    'avatar6.png',
    'avatar7.png',
    'avatar8.png',
  ];

  @override
  void onInit() {
    super.onInit();
    currentUser = UserSession().currentUser;
    tempAvatar.value = currentUser!.avatar;
  }

  // Called when user taps an avatar in the bottom sheet
  void selectAvatar(String filename) {
    tempAvatar.value = filename; // Only updates UI, does not save to DB yet
    Get.back(); // Close bottom sheet
  }

  // Called when user clicks "Save" in the AppBar
  Future<void> saveSettings() async {
    final userId = currentUser?.authId;

    // Save to Supabase via Service
    final success = await _profileService.updateAvatar(
      userId!,
      tempAvatar.value,
    );

    if (success) {
      UserSession().currentUser!.avatar = tempAvatar.value;

      Get.snackbar(
        "Success".tr,
        "Profile updated successfully!".tr,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error".tr,
        "Failed to save changes. Please try again.".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

   void toggleNotifications(bool value) => pushNotifications.value = value;
  void toggleDarkMode(bool value) {
    if (value != themeController.isDarkMode.value) {
      themeController.toggleTheme();
    }
  }
  void logout() {
    final service = Get.find<AuthService>();
    service.logout();
    Get.offAllNamed('/login');
  }

  void deleteAccount() {
    Get.defaultDialog(
      title: "Delete Account".tr,
      middleText: "Are you sure? This cannot be undone..".tr,
      textConfirm: "Delete".tr,
      textCancel: "Cancel".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        final service = Get.find<AuthService>();
        final success = await service.deleteAccount();
        if (success) {
          Get.offAllNamed('/login');
        } else {
          Get.back();
          Get.snackbar("Error".tr, "Failed to delete account.".tr);
        }
      },
    );
  }
}
