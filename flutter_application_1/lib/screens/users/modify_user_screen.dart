import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/role_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/department_controller.dart';
import 'package:flutter_application_1/models/department.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:flutter_application_1/models/role.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:provider/provider.dart';

class ModifyUserPage extends StatefulWidget {
  final User user;
  const ModifyUserPage({super.key, required this.user});

  @override
  _ModifyUserPageState createState() => _ModifyUserPageState();
}

class _ModifyUserPageState extends State<ModifyUserPage> {
  late UserController userController ;
  late RoleController roleController;
  late DepartmentController departmentController;
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
  late Future<User?> _userFuture;
  File? _profileImageFile;
  Role? selectedRole;
  Department? selectedDepartment;

  @override
  void initState() {
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
    roleController = Provider.of<RoleController>(context, listen: false);
    departmentController = Provider.of<DepartmentController>(context, listen: false);
    roleController.fetchRoles();
    departmentController.fetchDepartments();
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
        _firstNameController.text = user.firstName ?? user.profile?.firstName ?? '';
        _lastNameController.text = user.lastName ?? user.profile?.lastName ?? '';
        _emailController.text = user.email ?? '';
        _usernameController.text = user.username ?? '';
        _countryController.text = user.profile?.country ?? '';
        _stateController.text = user.profile?.state ?? '';
        _cityController.text = user.profile?.city ?? '';
        _addressController.text = user.profile?.address ?? '';
        _locationController.text = user.profile?.location ?? '';
        _zipCodeController.text = user.profile?.zipCode?.toString() ?? '';

        // Try obtaining the full user object (which may include dep_id) via viewUser
        try {
          final fetchedUser = await UserNetwork().viewUser(widget.user.id!);
          if (fetchedUser != null) {
            final int? deptId = fetchedUser.depId;
            if (deptId != null) {
              // ensure departments are loaded
              await departmentController.fetchDepartments();
              final depts = departmentController.departments;
              final found = depts.firstWhere((d) => d.id == deptId, orElse: () => depts.isNotEmpty ? depts.first : Department(id: null, name: ''));
              if (found.id != null) {
                // Defer state change to avoid calling setState during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      selectedDepartment = found;
                    });
                  }
                });
              }
            }
          }
        } catch (e) {
          // ignore
        }

        return user;
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
          Consumer<UserController>(
            builder: (context, userController, child) {
              final loading = userController.isLoading;
              final canSave = !loading && selectedRole != null;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6F4DBF),
                    elevation: 0,
                  ),
                  onPressed: canSave ? () async {
                    // Debug: show what will be sent
                    try {
                      // ignore: avoid_print
                      print('ModifyUser: sending -> role=${selectedRole?.id}, dep=${selectedDepartment?.id}');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Envoi: role=${selectedRole?.id}, dep=${selectedDepartment?.id}')));
                    } catch (e) {}

                    final error = await userController.updateAllUser(
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
                      selectedRole!,
                      selectedDepartment,
                      context,
                    );
                    if (error != null) {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                      } catch (e) {}
                    }
                  } : null,
                  icon: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFF6F4DBF), strokeWidth: 2))
                    : const Icon(Icons.save, size: 18),
                  label: Text(loading ? 'Saving...' : 'Save'),
                ),
              );
            }
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
                const Divider(height: 32),
                const Text('Role', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6F4DBF))),
                const SizedBox(height: 16),
                Consumer<RoleController>(
                  builder: (context, roleController, child) {
                    // Find the matching role instance from the list
                    if (widget.user.role != null) {
                      selectedRole = roleController.roles.firstWhere(
                        (role) => role.id == widget.user.role!.id,
                        // orElse: () => roleController.roles.isNotEmpty ? roleController.roles.first : null,
                      );
                    }

                    return DropdownButtonFormField<Role>(
                      initialValue: selectedRole,
                      items: roleController.roles.map((role) {
                        return DropdownMenuItem<Role>(
                          value: role,
                          child: Text(role.name ?? 'Member'),
                        );
                      }).toList(),
                      onChanged: (role) {
                        if (role != null) {
                          setState(() {
                            widget.user.role = role;
                            selectedRole = role;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Role',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<DepartmentController>(
                  builder: (context, deptCtrl, child) {
                    return DropdownButtonFormField<Department>(
                      value: selectedDepartment,
                      items: deptCtrl.departments.map((d) => DropdownMenuItem<Department>(
                        value: d,
                        child: Text(d.name),
                      )).toList(),
                      onChanged: (d) {
                        setState(() {
                          selectedDepartment = d;
                        });
                        // Debug log to verify selection
                        try {
                          // ignore: avoid_print
                          print('ModifyUser: selected department -> id=${d?.id}, name=${d?.name}');
                        } catch (e) {}
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Department',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
