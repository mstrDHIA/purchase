import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/profile_network.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application_1/models/user.dart'; // <-- Assure-toi que ce chemin est correct
import 'package:flutter_application_1/network/user_network.dart'; // <-- Assure-toi que ce chemin est correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add User',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      
    );
  }
}



class AddUserPage extends StatefulWidget {
  final String? email;
  final int? userId;
  const AddUserPage({Key? key, this.email, this.userId}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  Future<bool> _userExists(String username, String email) async {
    final users = await UserNetwork().uesresList();
    return users.any((u) => u.username == username || u.email == email);
  }
  // final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  // final _passwordController = TextEditingController();
  String _selectedCountry = 'Tunisia';
  // String? _selectedRole = 'Member';

  final List<String> _countries = [
    'Tunisia', 'Poland', 'France', 'Germany', 'Spain',
    'Italy', 'USA', 'Canada', 'Morocco', 'Japan', 'China',
  ];

  File? _profileImage;
  String? _selectedAssetImage;

  @override
  void dispose() {
    // _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImageFromFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        _selectedAssetImage = null;
      });
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildLabeledBox(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(label),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Text('Navigation')),
            ListTile(title: Text('Home'), onTap: () {}),
            ListTile(title: Text('Dashboard'), onTap: () {}),
            ListTile(title: Text('Users'), selected: true, selectedTileColor: Colors.grey[200], onTap: () {}),
            ListTile(title: Text('Password'), onTap: () {}),
            ListTile(title: Text('Request Order'), onTap: () {}),
            ListTile(title: Text('Purchase Order'), onTap: () {}),
            ListTile(title: Text('Roles and Access'), onTap: () {}),
            ListTile(title: Text('Support Centre'), onTap: () {}),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'User Information Form',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        foregroundColor: const Color.fromARGB(255, 23, 13, 220),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons
            Row(
              children: [
                Expanded(child: SizedBox()),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_firstNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('First Name is required')),
                          );
                          return;
                        }

                        // Vérification doublon username/email (ici username = firstName, email = '')
                        

                        // 1. Créer l'utilisateur (User)
                        // Créer le profil lié à cet utilisateur déjà créé (userId transmis)
                        if (widget.userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur : ID utilisateur manquant pour le profil.")),
                          );
                          return;
                        }
                        Profile profile = Profile(
                          userId: widget.userId!,
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          address: _addressController.text,
                          city: _cityController.text,
                          state: _stateController.text,
                          country: _selectedCountry,
                        );
                        final message = await ProfileNetwork().addProfile(profile);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                        // Navigate to main screen after saving
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen()),
                        );
// Dummy main screen, replace with your actual main page
// class MainScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Main Screen')),
//       body: Center(child: Text('Welcome to the main screen!')),
//     );
//   }
// }
                      },
                      child: Text('Save'),
                    ),
                    SizedBox(height: 8),
                    
                    SizedBox(height: 8),
                   
                  ],
                ),
              ],
            ),
            SizedBox(height: 32),

            // Profile picture
            Center(
              child: Column(
                children: [
                  if (_profileImage != null)
                    Image.file(_profileImage!, width: 120, height: 120, fit: BoxFit.cover)
                  else if (_selectedAssetImage != null)
                    Image.asset(_selectedAssetImage!, width: 120, height: 120, fit: BoxFit.cover)
                  else
                    const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickProfileImageFromFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Open File to Select Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),




            Row(
              children: [
                Expanded(
                  child: _buildLabeledBox(
                    'First Name',
                    TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(hintText: 'Enter first name'),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildLabeledBox(
                    'Last Name',
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(hintText: 'Enter last name'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),



            _buildLabeledBox(
              'Address',
              TextField(controller: _addressController),
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildLabeledBox(
                    'City',
                    TextField(controller: _cityController),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildLabeledBox(
                    'State',
                    TextField(controller: _stateController),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildLabeledBox(
                    'ZIP',
                    TextField(controller: _zipController),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildLabeledBox(
                    'Country',
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                        });
                      },
                      items: _countries.map((country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
