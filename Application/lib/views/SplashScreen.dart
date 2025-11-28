import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/views/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // This is where the 3-second timer is set up.
    Timer(const Duration(seconds: 5), () {
      // After 3 seconds, it will replace the splash screen with the LoginScreen.
      final user = Get.find<SupabaseClient>().auth.currentUser;

      if (user != null) {
        Get.offAllNamed('/calculator_page');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a clean background color that matches your theme
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your Photo/Icon goes here
            Image.asset(
              "assets/photos/icons8-lightning-bolt-100.png",
              scale: 2,
            ),
            const SizedBox(height: 24),
            // A loading indicator to show that the app is preparing
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
