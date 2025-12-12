import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/login_form_controller.dart';
import '../utils/size_config.dart'; // Import SizeConfig for responsive sizing

class LoginForm extends GetView<LoginFormController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeConfig = SizeConfig.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/photos/icons8-lightning-bolt-100.png", scale: 2),
        // --- CHANGE 1: Using responsive fixed spacing instead of percentages ---
        SizedBox(height: sizeConfig.isMobile ? 20 : 30),
        Text(
          'Welcome!',
          style: TextStyle(
            fontSize: sizeConfig.isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 8 : 12),
        Text(
          "Sign in to continue",
          style: TextStyle(
            fontSize: sizeConfig.isMobile ? 16 : 20,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 40 : 50),
        _buildTextField(
          context: context,
          cont: controller.mailController,
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
        SizedBox(height: sizeConfig.isMobile ? 12 : 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Get.toNamed('forgot_password');
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: sizeConfig.isMobile ? 14 : 16,
              ),
            ),
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 24 : 32),
        _buildLoginButton(context, sizeConfig),
        SizedBox(height: sizeConfig.isMobile ? 32 : 40),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "OR",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ],
        ),
        SizedBox(height: sizeConfig.isMobile ? 24 : 32),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: sizeConfig.isMobile ? 14 : 16,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/register');
              },
              child: Text(
                'Sign Up',
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
      controller: cont,
      obscureText: obscureText,
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

  // Helper widget for the Login Button
  Widget _buildLoginButton(BuildContext context, SizeConfig sizeConfig) {
    return GestureDetector(
      onTap: () async {
        final email = controller.mailController.text.trim();
        final password = controller.passwordController.text.trim();
        if (email.isEmpty || password.isEmpty) {
          if (email.isEmpty) {
            Get.snackbar(
              "Error",
              "Email field cannot be empty",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }

          if (password.isEmpty) {
            Get.snackbar(
              "Error",
              "Password field cannot be empty",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }

          return;
        }

        try {
          final success = await controller.login(
            controller.mailController.text.trim(),
            controller.passwordController.text.trim(),
          );

          if (success) {
            Get.offAllNamed('/main_shell');
          }
        } on AuthApiException catch (e) {
          if (e.code == 'email_not_confirmed') {
            Get.snackbar(
              "Login Failed",
              "Email not Confirmed",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else if (e.code == 'invalid_credentials') {
            Get.snackbar(
              "Login Failed",
              "Invalid email or password",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      },

      child: Container(
        // --- CHANGE 3: Made button padding responsive ---
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
            'Sign In',
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
