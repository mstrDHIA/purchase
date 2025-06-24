import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'add user',
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
      home: AddUserPage(),
    );
  }
}

class AddUserPage extends StatefulWidget {
  @override
  _AddProfilePageState createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State< AddUserPage> {
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController(text: 'Tunisia');

  String? _selectedRole = 'Member';

  final List<String> _countries = [
    'Tunisia',
    'Poland',
    'France',
    'Germany',
    'Spain',
    'Italy',
    'USA',
    'Canada',
    'Morocco',
    'Japan',
    'China',
  ];

  File? _profileImage;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  

  Future<void> _pickProfileImageFromFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        _selectedAssetImage = null; // Clear asset image if any
      });
    }
  }

  String? _selectedAssetImage;

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
            // Header row with title and buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    '',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Save logic
                      },
                      child: Text('Save'),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Save and Add Another
                      },
                      child: Text('Save & Add Another'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // <-- Ferme la page et retourne en arrière
                      },
                      child: Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.grey[200],
                        side: BorderSide.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32),

            // Profile picture selector
            Center(
              child: Column(
                children: [
                  // Show selected image (from file or asset) immediately
                  if (_profileImage != null)
                    Image.file(
                      _profileImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  else if (_selectedAssetImage != null)
                    Image.asset(
                      _selectedAssetImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  else
                    const CircleAvatar(
                      radius: 48,
                      child: Icon(Icons.person, size: 48),
                    ),
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

            _buildLabeledBox(
              'Email',
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'email@example.com'),
              ),
            ),
            SizedBox(height: 24),

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
              'Role',
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['Member', 'Admin', 'Editor', 'Viewer']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (newRole) => setState(() => _selectedRole = newRole),
                decoration: InputDecoration(),
              ),
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
                      value: _countryController.text,
                      onChanged: (value) {
                        setState(() {
                          _countryController.text = value!;
                        });
                      },
                      items: _countries.map((country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      )).toList(),
                      decoration: InputDecoration(),
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
