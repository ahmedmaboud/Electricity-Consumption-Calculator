import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final box = GetStorage();
  var isArabic = false.obs;

  @override
  void onInit() {
    super.onInit();
    String? langCode = box.read('lang');
    isArabic.value = (langCode == 'ar');
    Get.updateLocale(isArabic.value ? Locale('ar', 'EG') : Locale('en', 'US'));
  }

  void toggleLanguage(bool value) {
    isArabic.value = value;
    Locale newLocale = value ? Locale('ar', 'EG') : Locale('en', 'US');
    Get.updateLocale(newLocale);
    box.write('lang', value ? 'ar' : 'en');
  }
}
