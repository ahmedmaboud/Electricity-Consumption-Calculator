import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class UpdatePasswordController extends GetxController {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authService = Get.find<AuthService>();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  Future<void> updatePassword() async {
    String pass = passwordController.text;
    String confirm = confirmPasswordController.text;

    if (pass.isEmpty || pass.length < 6) {
      Get.snackbar(
        "Error".tr,
        "Password must be at least 6 characters".tr,
        backgroundColor: Colors.red.shade500,
        colorText: Colors.white,
      );
      return;
    }

    if (pass != confirm) {
      Get.snackbar(
        "Error".tr,
        "Passwords do not match".tr,
        backgroundColor: Colors.red.shade500,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await authService.updateUserPassword(pass);

      Get.snackbar(
        "Success".tr,
        "Password updated successfully!".tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to Login or Home after success
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        "Error".tr,
        "Failed to update password: $e".tr,
        backgroundColor: Colors.red.shade500,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
