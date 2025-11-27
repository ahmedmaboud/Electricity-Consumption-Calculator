import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/services/auth_service.dart';

class LoginFormController extends GetxController {
  final authService = Get.find<AuthService>();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    mailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> login(String mail, String password) async {
    return await authService.login(mail, password);
  }
}
