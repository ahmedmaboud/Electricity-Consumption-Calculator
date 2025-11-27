import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/services/auth_service.dart';

class RegisterFormController extends GetxController {
  final authService = Get.find<AuthService>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<bool> signUp(String email, String password, String name) async {
    return await authService.register(email, password, name);
  }
}
