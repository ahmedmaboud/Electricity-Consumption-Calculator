import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/services/auth_service.dart';

class RegisterFormController extends GetxController {
  final authService = Get.find<AuthService>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<bool> signUp(String email, String password, String name) async {
    return await authService.register(email, password, name);
  }

  bool validatePasswords(String pass, String confirmPass) {
    if (pass != confirmPass) {
      Get.snackbar(
        "Password Error",
        "Password and Confirm Password do not match!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }
}
