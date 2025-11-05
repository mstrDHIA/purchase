import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ThemeProvider.themes['Clair']!;
  String _themeName = 'Clair';

  static final Map<String, ThemeData> themes = {
    'Clair': ThemeData.light(),
    'Sombre': ThemeData.dark(),
    'Aurora': ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.teal.shade50,
      colorScheme: ColorScheme.light(primary: Colors.teal, secondary: Colors.purpleAccent),
      appBarTheme: AppBarTheme(backgroundColor: Colors.teal.shade200),
    ),
    'Prism': ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.deepPurple.shade50,
      colorScheme: ColorScheme.light(primary: Colors.deepPurple, secondary: Colors.cyanAccent),
      appBarTheme: AppBarTheme(backgroundColor: Colors.deepPurple.shade200),
    ),
    // Ajoute d'autres thèmes ici
  };

  ThemeData get currentTheme => _currentTheme;
  String get themeName => _themeName;

  Null get isDarkMode => null;

  void setTheme(String name) {
    if (themes.containsKey(name)) {
      _currentTheme = themes[name]!;
      _themeName = name;
      notifyListeners();
    }
  }

  void toggleTheme(bool val) {}
}

class FilterProvider extends ChangeNotifier {
  String _search = '';
  String get search => _search;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  // Add more filter fields as needed (date, status, etc.)
}