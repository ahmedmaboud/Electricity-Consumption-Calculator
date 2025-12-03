import 'dart:async';
import 'dart:ui';
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: double.infinity,
              child: Container(
                color: Colors.blue[700],
              ),
            ),
          ),
          Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.bolt,
                        color: Colors.blue[700],
                        size: 80,
                      ),
                    ),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}
