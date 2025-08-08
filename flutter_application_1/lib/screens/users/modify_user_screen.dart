import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/models/role.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ModifyUserPage extends StatefulWidget {
  final User user;
  const ModifyUserPage({super.key, required this.user});

  @override
  _ModifyUserPageState createState() => _ModifyUserPageState();
}

class _ModifyUserPageState extends State<ModifyUserPage> {
  late UserController userController ;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _locationController;
  late TextEditingController _zipCodeController;
  String? _error;
  // String? _role;

  late Future<User?> _userFuture;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _countryController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _addressController = TextEditingController();
    _locationController = TextEditingController();
    _zipCodeController = TextEditingController();
    _userFuture = _fetchUserDetails();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<User?> _fetchUserDetails() async {
    try {
      final userController = Provider.of<UserController>(context, listen: false);
      final user = await userController.getDetailedUser(widget.user.id!);
      if (user != null) {
        _firstNameController.text = user.firstName ?? user.profile?.firstName ?? '';
        _lastNameController.text = user.lastName ?? user.profile?.lastName ?? '';
        _emailController.text = user.email ?? '';
        _usernameController.text = user.username ?? '';
        // _role = user.role?.name ?? 'Member';
        _countryController.text = user.profile?.country ?? '';
        _stateController.text = user.profile?.state ?? '';
        _cityController.text = user.profile?.city ?? '';
        _addressController.text = user.profile?.address ?? '';
        _locationController.text = user.profile?.location ?? '';
        _zipCodeController.text = user.profile?.zipCode?.toString() ?? '';
        return user;
      }
    } catch (e) {
      _error = 'Erreur lors de la récupération: $e';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F4DBF),
        elevation: 0,
        title: const Text('User Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6F4DBF),
                elevation: 0,
              ),
              onPressed: () async {
                 

                // Prépare la requête pour updateAllUsers
                // final updateRequest = User(
                  
                //   username: _usernameController.text,
                //   email: _emailController.text,
                //   // firstName: _firstNameController.text,
                //   // lastName: _lastNameController.text,
                //   // isSuperuser: widget.user.isSuperuser,
                  
                //   profile: Profile(
                //     // id: widget.user.profile?.id,
                //     // bio: widget.user.profile?.bio,
                //     location: _locationController.text,
                //     country: _countryController.text,
                //     state: _stateController.text,
                //     city: _cityController.text,
                //     zipCode: int.tryParse(_zipCodeController.text),
                //     address: _addressController.text,
                //     firstName: _firstNameController.text,
                //     lastName: _lastNameController.text,
                //     // userId: widget.user.id ?? 0,
                //   ),
                //   // role: _role != null ? Role(name: _role!, description: '') : widget.user.role,
                // );



                // Appel API updateAllUsers
                // final result = await UserNetwork().updateAllUsers(updateRequest, widget.user.id!);
                await userController.updateAllUser(

                   _firstNameController.text,
                   _lastNameController.text,
                   _emailController.text,
                   _usernameController.text,
                   _countryController.text,
                   _stateController.text,
                   _cityController.text,
                   _addressController.text,
                   _locationController.text,
                   int.tryParse(_zipCodeController.text),
  
  

                );
                
                // Affiche le résultat
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text(result)),
                // );
              },
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save'),
            ),
          ),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo and username
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImageFile != null
                            ? FileImage(_profileImageFile!)
                            : null,
                        child: _profileImageFile == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Divider(height: 32),
                const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6F4DBF))),
                const SizedBox(height: 16),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _zipCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Zip code',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Function to handle profile photo change
  // Widget _buildProfilePhotoField(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Profile photo',
  //         style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black,
  //             ),
  //       ),
  //       const SizedBox(height: 8),
  //       Row(
  //         children: [
  //           CircleAvatar(
  //             radius: 32,
  //             backgroundColor: Colors.grey[300],
  //             backgroundImage: _profileImageFile != null
  //                 ? FileImage(_profileImageFile!)
  //                 : null,
  //             child: _profileImageFile == null
  //                 ? const Icon(Icons.person, size: 32, color: Colors.white)
  //                 : null,
  //           ),
  //           const SizedBox(width: 16),
  //           ElevatedButton(
  //             onPressed: _pickImage,
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.grey[200],
  //               foregroundColor: Colors.black,
  //               elevation: 0,
  //             ),
  //             child: const Text('Click to replace'),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

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
