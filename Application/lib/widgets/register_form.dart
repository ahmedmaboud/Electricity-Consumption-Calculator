import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/register_form_controller.dart';
import '../utils/size_config.dart';

class RegisterForm extends GetView<RegisterFormController> {
  const RegisterForm({super.key});
  @override
  Widget build(BuildContext context) {
    final sizeConfig = SizeConfig.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_add_alt_1_rounded,
          size: sizeConfig.isMobile ? 80 : 120,
          color: Colors.amber[600],
        ),
        SizedBox(height: sizeConfig.isMobile ? 20 : 30),
        Text(
          'Create Account'.tr,
          style: TextStyle(
            fontSize: sizeConfig.isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF212121),
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 8 : 12),
        Text(
          "Let's get you started!".tr,
          style: TextStyle(
            fontSize: sizeConfig.isMobile ? 16 : 20,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 40 : 50),
        _buildTextField(
          cont: controller.nameController,
          sizeConfig: sizeConfig,
          hintText: 'Full Name'.tr,
          prefixIcon: Icons.person_outline_rounded,
        ),
        SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
          cont: controller.emailController,
          sizeConfig: sizeConfig,
          hintText: 'Email Address'.tr,
          prefixIcon: Icons.email_outlined,
        ),
        SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
          cont: controller.passwordController,
          sizeConfig: sizeConfig,
          hintText: 'Password'.tr,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
          cont: controller.confirmPasswordController,
          sizeConfig: sizeConfig,
          hintText: 'Confirm Password'.tr,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        SizedBox(height: sizeConfig.isMobile ? 24 : 32),
        _buildRegisterButton(context, sizeConfig),
        SizedBox(height: sizeConfig.isMobile ? 24 : 32),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Already have an account?".tr,
              style: TextStyle(
                color: Colors.black54,
                fontSize: sizeConfig.isMobile ? 14 : 16,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Sign In'.tr,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: sizeConfig.isMobile ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper widget for TextFields
  Widget _buildTextField({
    required TextEditingController cont,
    required SizeConfig sizeConfig,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return TextField(
      obscureText: obscureText,
      controller: cont,
      style: TextStyle(fontSize: sizeConfig.isMobile ? 16 : 18),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: sizeConfig.isMobile ? 22.0 : 24.0,
          horizontal: 20.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
        ),
      ),
    );
  }

  // Helper widget for the Register Button
  Widget _buildRegisterButton(BuildContext context, SizeConfig sizeConfig) {
    return GestureDetector(
      onTap: () async {
        final name = controller.nameController.text.trim();
        final mail = controller.emailController.text.trim();
        final pass = controller.passwordController.text.trim();
        final confirm = controller.confirmPasswordController.text.trim();

        if (!controller.validateEmptyFields(name, mail, pass, confirm)) return;
        if (!controller.validateEmailFormat(mail)) return;
        if (!controller.validatePasswordLength(pass)) return;
        if (!controller.validatePasswords(pass, confirm)) return;

        final success = await controller.signUp(mail, pass, name);

        if (success) {
          Get.snackbar(
            "Success".tr,
            "Registration Success, Confirm your email".tr,
            backgroundColor: Colors.blue.shade400,
            colorText: Colors.white,
          );
          Get.offAllNamed('/login');
        } else {
          Get.snackbar(
            "Error".tr,
            "Registration failed".tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },

      child: Container(
        padding: EdgeInsets.symmetric(vertical: sizeConfig.isMobile ? 18 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Sign Up'.tr,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: sizeConfig.isMobile ? 18 : 20,
            ),
          ),
        ),
      ),
    );
  }
}
