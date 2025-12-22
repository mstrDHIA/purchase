import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  // Default to English
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocaleFromPrefs();
  }

  Future<void> _loadLocaleFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('language');
      if (lang != null) {
        if (lang == 'English') {
          _locale = const Locale('en');
        } else if (lang == 'Français' || lang == 'French' || lang == 'fr') {
          _locale = const Locale('fr');
        } else {
          _locale = const Locale('ar');
        }
        notifyListeners();
      }
    } catch (_) {
      // ignore errors and keep default
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = locale.languageCode;
      final lang = (code == 'en') ? 'English' : (code == 'fr') ? 'Français' : 'العربية';
      await prefs.setString('language', lang);
    } catch (_) {}
  }
}