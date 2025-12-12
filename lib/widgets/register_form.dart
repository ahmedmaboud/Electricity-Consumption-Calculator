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
          'Create Account',
          style: TextStyle(
            fontSize: sizeConfig.isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 8 : 12),
        Text(
          "Let's get you started!",
          style: TextStyle(
            fontSize: sizeConfig.isMobile ? 16 : 20,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 40 : 50),
        _buildTextField(
          context: context,
          cont: controller.nameController,
          sizeConfig: sizeConfig,
          hintText: 'Full Name',
          prefixIcon: Icons.person_outline_rounded,
        ),
        SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
          context: context,
          cont: controller.emailController,
          sizeConfig: sizeConfig,
          hintText: 'Email Address',
          prefixIcon: Icons.email_outlined,
        ),
        SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
          context: context,
          cont: controller.passwordController,
          sizeConfig: sizeConfig,
          hintText: 'Password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
          context: context,
          cont: controller.confirmPasswordController,
          sizeConfig: sizeConfig,
          hintText: 'Confirm Password',
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
              "Already have an account?",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: sizeConfig.isMobile ? 14 : 16,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
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
    required BuildContext context,
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
        prefixIcon: Icon(
          prefixIcon,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
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
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
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
            "Success",
            "Registration Success, Confirm your email",
            backgroundColor: Colors.blue.shade400,
            colorText: Colors.white,
          );
          Get.offAllNamed('/login');
        } else {
          Get.snackbar(
            "Error",
            "Registration failed",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },

      child: Container(
        padding: EdgeInsets.symmetric(vertical: sizeConfig.isMobile ? 18 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).primaryColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Sign Up',
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
