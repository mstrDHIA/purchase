import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/screens/users/password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserController userController;
  bool _notificationsEnabled = true;
  String _selectedLanguage = "English";
  Map<String, dynamic> user = {};

  @override
  void initState() {
    userController = Provider.of<UserController>(context, listen: false);
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString("language");
    if (lang == null) {
      await prefs.setString("language", "English");
      setState(() {
        _selectedLanguage = "English";
      });
    } else {
      setState(() {
        _selectedLanguage = lang;
      });
    }
  }

  Future<void> _saveLanguagePreference(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", lang);
    setState(() => _selectedLanguage = lang);
  }

  @override
  Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final themeName = themeProvider.themeName;
  final loc = AppLocalizations.of(context)!;
  // Récupérer l'utilisateur connecté depuis le UserController
  final userData = Provider.of<UserController>(context).currentUser;
  // Compose display name from firstName/lastName or username
  String userName = '';
  if ((userData.firstName != null && userData.firstName!.isNotEmpty) || (userData.lastName != null && userData.lastName!.isNotEmpty)) {
    userName = '${userData.firstName ?? ''} ${userData.lastName ?? ''}'.trim();
  } else if (userData.username != null && userData.username!.isNotEmpty) {
    userName = userData.username!;
  } else {
  userName = loc.userName;
  }
  final userEmail = userData.email ?? loc.userEmail;
  // Afficher la vraie photo de profil si disponible, sinon image par défaut
  String userAvatar = 'assets/images/Company.jpg';
  if (userData.profile != null) {
    final profile = userData.profile!;
    // Utiliser le champ bio comme chemin d'image si c'est une image
    if (profile.bio != null && profile.bio!.isNotEmpty && (profile.bio!.endsWith('.jpg') || profile.bio!.endsWith('.png'))) {
      userAvatar = profile.bio!;
    }
  }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage(userAvatar),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ==== ACCOUNT SETTINGS ====
          _buildSectionTitle("Account Settings"),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ==== APP SETTINGS ====
          _buildSectionTitle("App Preferences"),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // ==== NOTIFICATIONS ====
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: Text(_notificationsEnabled ? "Enabled" : "Disabled"),
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? "Notifications enabled"
                            : "Notifications disabled"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),

                // ==== LANGUAGE ====
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(loc.language),
                  trailing: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: DropdownButton<String>(
                      key: ValueKey(_selectedLanguage),
                      value: _selectedLanguage,
                      items: [
                        DropdownMenuItem(
                          value: "Français",
                          child: Row(
                            children: [
                              Icon(Icons.check, color: Colors.blue, size: 18),
                              SizedBox(width: 6),
                              Text(loc.french),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "English",
                          child: Text(loc.english),
                        ),
                        DropdownMenuItem(
                          value: "العربية",
                          child: Text(loc.arabic),
                        ),
                      ],
                      onChanged: (String? lang) {
                        if (lang != null) {
                          _saveLanguagePreference(lang);
                          // Changement dynamique de la langue
                          final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                          if (lang == "English") {
                            localeProvider.setLocale(const Locale('en'));
                          } else if (lang == "Français") {
                            localeProvider.setLocale(const Locale('fr'));
                          } else if (lang == "العربية") {
                            localeProvider.setLocale(const Locale('ar'));
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.languageChanged(lang)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ==== THEME SECTION ====
          _buildSectionTitle("Appearance"),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Choose Theme'),
              subtitle: Text(themeName),
              trailing: DropdownButton<String>(
                value: themeName,
                items: ThemeProvider.themes.keys.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (String? name) {
                  if (name != null) {
                    themeProvider.setTheme(name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Theme changed to $name"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ==== INFO & LOGOUT ====
          _buildSectionTitle("About & Security"),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "My Application",
                      applicationVersion: "1.0.0",
                      applicationLegalese: "© 2025 Jasser Boubaker",
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Do you really want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              userController.logout(context);
                            },
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class FilterProvider extends ChangeNotifier {
  String _search = '';
  String get search => _search;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }
}
