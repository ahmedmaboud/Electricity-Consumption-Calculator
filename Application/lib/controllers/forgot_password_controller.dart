import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final authService = Get.find<AuthService>();

  var isLoading = false.obs;

  Future<void> sendResetLink() async {
    String email = emailController.text.trim();

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error".tr,
        "Please enter a valid email address".tr,
        backgroundColor: Colors.red.shade500,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await authService.sendPasswordResetEmail(email);

      // Success Feedback
      Get.defaultDialog(
        title: "Check your email".tr,
        middleText: "We have sent a password reset link to %s.".trArgs([email]),
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Close dialog
          Get.back(); // Go back to login
        },
      );
    } catch (e) {
      Get.snackbar(
        "Error".tr,
        "Failed to send reset link: %s".trArgs([e.toString()]),
        backgroundColor: Colors.red.shade500,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
