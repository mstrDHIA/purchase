import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:image_picker/image_picker.dart';

class ModifyUserPage extends StatefulWidget {
  final User user;
  const ModifyUserPage({required this.user});

  @override
  _ModifyUserPageState createState() => _ModifyUserPageState();
}

class _ModifyUserPageState extends State<ModifyUserPage> {
  late TextEditingController _passwordController;
  // Text controllers for fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _usernameController = TextEditingController(text: widget.user.username);
    _passwordController = TextEditingController();
  }

  // For profile image
  File? _profileImageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              // Handle profile icon tap
            },
          ),
          SizedBox(width: 16.0),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : AssetImage('assets/images/j.png') as ImageProvider,
                    onBackgroundImageError: (_, __) {}, // Handle any error for background image
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amélie Laurent', // You can dynamically change the name here
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Amélie@untitledui.com', // You can dynamically change the email here
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Handle copy link or any other action
                    },
                    child: Text('Copy link'),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              // Form fields
              const Text(
                'Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'First Name',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Last Name',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),

              Text(
                'Email address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),

              Text(
                'Username',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        bottomLeft: Radius.circular(4.0),
                      ),
                    ),
                    child: Text('untitledui.com/', style: TextStyle(color: Colors.grey[700])),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4.0),
                            bottomRight: Radius.circular(4.0),
                          ),
                        ),
                        suffixIcon: Icon(Icons.check_circle, color: Colors.blue), // Example check icon
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),

              Text(
                'Role',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: 'Member', // Initial value
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: <String>['Member', 'Admin', 'Editor', 'Viewer']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Handle role change
                },
              ),
              SizedBox(height: 32.0),

              // Profile photo section
              _buildProfilePhotoField(context),
              SizedBox(height: 48.0),

              // Bottom buttons
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Show confirmation dialog before deleting
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete User'),
                          content: const Text('Are you sure you want to delete this user?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Go back to previous page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User deleted')),
                                );
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Delete user',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back without saving
                    },
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      // Récupère les valeurs modifiées depuis tes contrôleurs ou ton formulaire
                      User updatedUser = User(
                        id: widget.user.id,
                        username: _usernameController.text,
                        email: _emailController.text,
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        isSuperuser: widget.user.isSuperuser,
                        password: _passwordController.text,
                      );

                      print(updatedUser.toJson());

                      String result = await UserNetwork().updateUser(updatedUser);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result)),
                      );

                      if (result.contains('success')) {
                        Navigator.pop(context); // Retour à la liste après succès
                      }
                    },
                    child: const Text('Save changes'),
                  ),
              // Password field
              const Text(
                'Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter password',
                ),
              ),
              SizedBox(height: 16.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to handle profile photo change
  Widget _buildProfilePhotoField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile photo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[300],
              backgroundImage: _profileImageFile != null
                  ? FileImage(_profileImageFile!)
                  : null,
              child: _profileImageFile == null
                  ? const Icon(Icons.person, size: 32, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              child: const Text('Click to replace'),
            ),
          ],
        ),
      ],
    );
  }
}
