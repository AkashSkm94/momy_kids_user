import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en');

  Locale get appLocal => _appLocale;
  Future<Locale> fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('en');
      return _appLocale;
    }

    _appLocale = Locale(prefs.getString('language_code')!);
    print("#### _appLocale $_appLocale");
    return _appLocale;
  }

  Future<void> changeLanguage(Locale type) async {
    print("#### _appLocale type $type");
    var prefs = await SharedPreferences.getInstance();
    // if (_appLocale == type) {
    //   return;
    // }
    if (type == Locale("ar")) {
      _appLocale = Locale("ar");
      await prefs.setString('language_code', 'ar');
      await prefs.setString('language_name', 'arabic');
      await prefs.setString('countryCode', '');
    }  else {
      _appLocale = Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('language_name', 'English');
      await prefs.setString('countryCode', '');
    }
    notifyListeners();
  }
}