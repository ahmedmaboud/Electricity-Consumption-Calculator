import 'package:flutter/material.dart';
import '../utils/size_config.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeConfig = SizeConfig.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              // Constrain the width for larger screens for better readability
              constraints: const BoxConstraints(maxWidth: 500),
              padding: EdgeInsets.symmetric(
                horizontal:
                    sizeConfig.screenWidth *
                    (sizeConfig.isMobile ? 0.08 : 0.04),
              ),
              child: RegisterForm(),
            ),
          ),
        ),
      ),
    );
  }
}
