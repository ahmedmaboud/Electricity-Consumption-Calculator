import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graduation_project_depi/controllers/analytics_page_controller.dart';
import 'package:graduation_project_depi/controllers/calculator_page_controller.dart';
import 'package:graduation_project_depi/services/budget_service.dart';
import 'package:graduation_project_depi/services/electricity_reading_service.dart';
import 'package:graduation_project_depi/views/budget_screen.dart';
import 'package:graduation_project_depi/views/profile_screen.dart';
import 'package:graduation_project_depi/views/updated_password_screen.dart';
import 'package:graduation_project_depi/user_session.dart';
import 'package:graduation_project_depi/views/RegisterPgae.dart';
import 'package:graduation_project_depi/views/SplashScreen.dart';
import 'package:graduation_project_depi/views/loginPage.dart';
import 'package:graduation_project_depi/views/main_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/budget_controller.dart';
import 'controllers/forgot_password_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/login_form_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/register_form_controller.dart';
import 'controllers/updated_password_controller.dart';
import 'views/forgot_password_screen.dart';
import 'services/auth_service.dart';
import 'language/app_translation.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Supabase.initialize(
    url: 'https://lavpockbisipvcxkrwsy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhdnBvY2tiaXNpcHZjeGtyd3N5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NTc4MTEsImV4cCI6MjA3NjUzMzgxMX0.UjoW6xeM9QmScS9JNjV_iP8DBYorlySpRuL4BsU_NhI',
  );

  try {
    await UserSession().loadUserInfo();
  } catch (_) {}

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  String? langCode = GetStorage().read('lang');

  runApp(MyApp(langCode: langCode));
}

class MyApp extends StatelessWidget {
  final String? langCode;
  const MyApp({super.key, this.langCode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslation(),
      locale: langCode != null ? Locale(langCode!) : Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
      initialBinding: BindingsBuilder(() {
        Get.put<SupabaseClient>(Supabase.instance.client);
        Get.put<AuthService>(AuthService());
        Get.put<ElectricityReadingService>(ElectricityReadingService());
        Get.put<BudgetService>(BudgetService());
        Get.put<LanguageController>(LanguageController());
      }),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash_screen',
      getPages: [
        GetPage(name: '/splash_screen', page: () => SplashScreen()),
        GetPage(
          name: '/main_shell',
          page: () => MainShell(),
          binding: BindingsBuilder(() {
            Get.lazyPut<CalculatorPageController>(
              () => CalculatorPageController(),
            );
            Get.lazyPut<ProfileController>(() => ProfileController());
            Get.lazyPut<HistoryController>(() => HistoryController());
            Get.lazyPut<AnalyticsController>(() => AnalyticsController());
            Get.lazyPut<BudgetController>(() => BudgetController());
          }),
        ),
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
          binding: BindingsBuilder(
            () => Get.lazyPut<RegisterFormController>(
              () => RegisterFormController(),
            ),
          ),
        ),
        GetPage(
          name: '/forgot_password',
          page: () => const ForgotPasswordScreen(),
          binding: BindingsBuilder(
            () => Get.lazyPut(() => ForgotPasswordController()),
          ),
        ),
        GetPage(
          name: '/update_password',
          page: () => const UpdatePasswordScreen(),
          binding: BindingsBuilder(
            () => Get.lazyPut(() => UpdatePasswordController()),
          ),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          binding: BindingsBuilder(
            () => Get.lazyPut<ProfileController>(() => ProfileController()),
          ),
        ),
        GetPage(
          name: '/budget',
          page: () => const BudgetScreen(),
          binding: BindingsBuilder(
            () => Get.lazyPut<BudgetController>(() => BudgetController()),
          ),
        ),
      ],
    );
  }
}
