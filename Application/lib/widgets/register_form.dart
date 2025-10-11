import 'package:flutter/material.dart';
import '../utils/size_config.dart';

class RegisterForm extends StatelessWidget {
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
            color: const Color(0xFF212121),
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 8 : 12),
        Text(
          "Let's get you started!",
          style: TextStyle(
            fontSize: sizeConfig.isMobile ? 16 : 20,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: sizeConfig.isMobile ? 40 : 50),
        _buildTextField(
          sizeConfig: sizeConfig,
          hintText: 'Full Name',
          prefixIcon: Icons.person_outline_rounded,
        ),
        SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
          sizeConfig: sizeConfig,
          hintText: 'Email Address',
          prefixIcon: Icons.email_outlined,
        ),
        SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
          sizeConfig: sizeConfig,
          hintText: 'Password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
         SizedBox(height: sizeConfig.isMobile ? 16 : 24),
        _buildTextField(
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
                color: Colors.black54,
                fontSize: sizeConfig.isMobile ? 14 : 16,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate back to the login screen
                Navigator.pop(context);
              },
              child: Text(
                'Sign In',
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
    required SizeConfig sizeConfig,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return TextField(
      obscureText: obscureText,
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
      onTap: () {
        // TODO: Implement registration logic
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
            )
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
