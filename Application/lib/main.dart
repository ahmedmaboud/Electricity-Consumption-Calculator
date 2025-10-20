import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/user_session.dart';
import 'package:graduation_project_depi/views/SplashScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

final cloud = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
