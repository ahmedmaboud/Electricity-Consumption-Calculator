import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  static const String _themeKey = 'isDarkMode';

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    isDarkMode.value = _storage.read(_themeKey) ?? false;
    update();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write(_themeKey, isDarkMode.value);
    update();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
