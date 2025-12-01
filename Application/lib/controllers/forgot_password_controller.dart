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
        "Error",
        "Please enter a valid email address",
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
        title: "Check your email",
        middleText: "We have sent a password reset link to $email.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Close dialog
          Get.back(); // Go back to login
        },
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send reset link: $e",
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
