import 'package:flutter/material.dart';
import '../utils/size_config.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeConfig = SizeConfig.of(context);

    // The layout is now a simple Center widget, which is perfect for a single form.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              // Constrain the width on larger screens for better readability
              constraints: const BoxConstraints(maxWidth: 500),
              padding: EdgeInsets.symmetric(
                // Use a different padding for mobile vs. larger screens
                horizontal:
                    sizeConfig.screenWidth *
                    (sizeConfig.isMobile ? 0.08 : 0.04),
              ),
              child: LoginForm(),
            ),
          ),
        ),
      ),
    );
  }
}
