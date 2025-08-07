import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/role.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  String? _error;
  String? _role;

  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _userFuture = _fetchUserDetails();
  }

  Future<User?> _fetchUserDetails() async {
    setState(() { });
    try {
      final user = await UserNetwork().getUserDetails(widget.user.id!);
      if (user != null) {
        // Do not set controllers here, only return user
        return user;
      }
    } catch (e) {
      _error = 'Erreur lors de la récupération: $e';
    } finally {
      setState(() { });
    }
    return null;
  }

  // For profile image
  File? _profileImageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(width: 16.0),
        ],
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || _error != null) {
            return Center(child: Text(_error ?? 'Erreur lors de la récupération', style: TextStyle(color: Colors.red)));
          }
          // Debug: print snapshot and controller values
          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            print('FutureBuilder: user.firstName=${user.firstName}, user.lastName=${user.lastName}, user.email=${user.email}, user.username=${user.username}, user.role=${user.role?.name}');
            print('Before assign: firstNameController=${_firstNameController.text}, lastNameController=${_lastNameController.text}, emailController=${_emailController.text}, usernameController=${_usernameController.text}');
            if (_firstNameController.text.isEmpty && _lastNameController.text.isEmpty && _emailController.text.isEmpty && _usernameController.text.isEmpty) {
              _firstNameController.text = user.firstName ?? '';
              _lastNameController.text = user.lastName ?? '';
              _emailController.text = user.email ?? '';
              _usernameController.text = user.username ?? '';
              _role = user.role?.name ?? 'Member';
              print('After assign: firstNameController=${_firstNameController.text}, lastNameController=${_lastNameController.text}, emailController=${_emailController.text}, usernameController=${_usernameController.text}');
            }
          }
          return SingleChildScrollView(
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
                          : null,
                      child: _profileImageFile == null
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_firstNameController.text} ${_lastNameController.text}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _emailController.text,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                const Text('Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Last Name',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Email address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          bottomLeft: Radius.circular(4.0),
                        ),
                      ),
                      child: Text('untitledui.com/', style: TextStyle(color: Colors.grey[700])),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4.0),
                              bottomRight: Radius.circular(4.0),
                            ),
                          ),
                          suffixIcon: Icon(Icons.check_circle, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
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
                    setState(() {
                      _role = newValue;
                    });
                  },
                ),
                const SizedBox(height: 32.0),
                Text('Profile photo', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImageFile != null ? FileImage(_profileImageFile!) : null,
                      child: _profileImageFile == null ? const Icon(Icons.person, size: 32, color: Colors.white) : null,
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
                const SizedBox(height: 16.0),
                const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter password (leave blank to keep unchanged)',
                  ),
                ),
                const SizedBox(height: 32.0),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
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
                                  Navigator.pop(context);
                                  Navigator.pop(context);
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
                      label: const Text('Delete user', style: TextStyle(color: Colors.red)),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        // Use UserController for update
                        User updatedUser = User(
                          id: widget.user.id,
                          username: _usernameController.text,
                          email: _emailController.text,
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          isSuperuser: widget.user.isSuperuser,
                          password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
                          role: _role != null ? Role(name: _role!, description: '') : widget.user.role,
                        );
                        final userController = Provider.of<UserController>(context, listen: false);
                        String result = await userController.updateUser(updatedUser);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                        if (result.contains('success')) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save changes'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      //               },
      //               child: const Text('Cancel'),
      //             ),
      //             SizedBox(width: 16.0),
      //             ElevatedButton(
      //               onPressed: () async {
      //                 // Récupère les valeurs modifiées depuis tes contrôleurs ou ton formulaire
      //                 User updatedUser = User(
      //                   id: widget.user.id,
      //                   username: _usernameController.text,
      //                   email: _emailController.text,
      //                   firstName: _firstNameController.text,
      //                   lastName: _lastNameController.text,
      //                   isSuperuser: widget.user.isSuperuser,
      //                   password: _passwordController.text,
      //                   profileId: widget.user.profileId,
      //                   role: widget.user.role,
      //                 );
      //
      //                 print(updatedUser.toJson());
      //
      //                 String result = await UserNetwork().updateUser(updatedUser);
      //
      //                 ScaffoldMessenger.of(context).showSnackBar(
      //                   SnackBar(content: Text(result)),
      //                 );
      //
      //                 if (result.contains('successfully')) {
      //                   Navigator.pop(context); // Retour à la liste après succès
      //                 }
      //               },
      //               child: const Text('Save changes'),
      //             ),
      //         // Password field
      //         const Text(
      //           'Password',
      //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //         ),
      //         const SizedBox(height: 8.0),
      //         TextField(
      //           controller: _passwordController,
      //           obscureText: true,
      //           decoration: const InputDecoration(
      //             border: OutlineInputBorder(),
      //             hintText: 'Enter password',
      //           ),
      //         ),
      //         SizedBox(height: 16.0),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
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

  // Add this method to pick an image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }
}
