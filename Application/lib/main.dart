import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/user_session.dart';
import 'package:graduation_project_depi/views/RegisterPgae.dart';
import 'package:graduation_project_depi/views/SplashScreen.dart';
import 'package:graduation_project_depi/views/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'calculator_page.dart';
import 'controllers/login_form_controller.dart';
import 'controllers/register_form_controller.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lavpockbisipvcxkrwsy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhdnBvY2tiaXNpcHZjeGtyd3N5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NTc4MTEsImV4cCI6MjA3NjUzMzgxMX0.UjoW6xeM9QmScS9JNjV_iP8DBYorlySpRuL4BsU_NhI',
  );

  await UserSession().loadUserInfo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<SupabaseClient>(() => Supabase.instance.client);
        Get.lazyPut<AuthService>(() => AuthService());
      }),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash_screen',
      // home: FirstPage(),
      getPages: [
        GetPage(name: '/splash_screen', page: () => SplashScreen()),
        GetPage(name: '/calculator_page', page: () => CalculatorPage()),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          binding: BindingsBuilder(
            () => Get.lazyPut<LoginFormController>(() => LoginFormController()),
          ),
        ),
        GetPage(
          name: '/register',
          page: () => RegisterScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut<RegisterFormController>(() => RegisterFormController());
          }),
        ),
      ],
    );
  }
}
