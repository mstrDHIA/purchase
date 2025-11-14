import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddUserPage extends StatefulWidget {
  final String? email;
  final int? userId;
  const AddUserPage({super.key, this.email, this.userId});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final String _selectedCountry = 'Tunisia';
  final List<String> _countries = [
    'Tunisia', 'Poland', 'France', 'Germany', 'Spain',
    'Italy', 'USA', 'Canada', 'Morocco', 'Japan', 'China',
  ];
  File? _profileImage;
  String? _selectedAssetImage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            const SizedBox(height: 60),
                      const Text(
                        'Username',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your username',
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 24),
                      const Text(
                        'Confirm Password',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Re-enter your password',
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Consumer<UserController>(
                        builder: (context, userController, child) {
                          return ElevatedButton(onPressed: (){
                            if (_usernameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Username is required')),
                              );
                              return;
                            }
                            if (_passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password is required')),
                              );
                              return;
                            }
                            if (_confirmPasswordController.text != _passwordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match')),
                              );
                              return;
                            }
                            userController.addUser(_usernameController.text, _passwordController.text, context);
                          }, child: Text('Save'));
                        }
                      ),
          ],
        ),
      ),
    );
  }
}
