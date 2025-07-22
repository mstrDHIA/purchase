import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:image_picker/image_picker.dart';

class Profileuserpage extends StatefulWidget {
  final User user;
  const Profileuserpage({required this.user});

  @override
  _ProfileuserpageState createState() => _ProfileuserpageState();
}

class _ProfileuserpageState extends State<Profileuserpage> {
  // Text controllers for fields
  final TextEditingController _firstNameController = TextEditingController(text: 'Amélie');
  final TextEditingController _lastNameController = TextEditingController(text: 'Laurent');
  final TextEditingController _emailController = TextEditingController(text: 'Amélie@untitledui.com');
  final TextEditingController _usernameController = TextEditingController(text: 'amelie');

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
       
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
                      enabled: false,
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
                      enabled: false,
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
                enabled: false,
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
                      enabled: false,
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
                onChanged: null, // Disable changing role
                disabledHint: Text('Member'),
              ),
              SizedBox(height: 32.0),

              // Profile photo section
             
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
                          title: const Text('Delete User',),
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
                  
                  SizedBox(width: 16.0),
                 
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to handle profile photo change
 
}
