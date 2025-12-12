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

  bool validateEmptyFields(
    String name,
    String email,
    String pass,
    String confirmPass,
  ) {
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        "Missing Fields",
        "Please fill in all fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  bool validateEmailFormat(String email) {
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");

    if (!emailRegex.hasMatch(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  bool validatePasswordLength(String pass) {
    if (pass.length < 6) {
      Get.snackbar(
        "Weak Password",
        "Password must be at least 6 characters long",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  bool validatePasswords(String pass, String confirmPass) {
    if (pass != confirmPass) {
      Get.snackbar(
        "Password Error".tr,
        "Password and Confirm Password do not match!".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }
}
