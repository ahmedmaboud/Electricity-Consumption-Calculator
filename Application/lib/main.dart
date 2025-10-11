import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/views/SplashScreen.dart';
import 'package:graduation_project_depi/views/loginPage.dart';
import 'utils/ocr_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false);
  }
}
