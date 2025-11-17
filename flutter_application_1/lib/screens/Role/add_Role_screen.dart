import 'package:flutter/material.dart';
import 'package:flutter_application_1/network/role_network.dart';

class AddRolePage extends StatefulWidget {
  const AddRolePage({super.key});

  @override
  State<AddRolePage> createState() => _AddRolePageState();
}

class _AddRolePageState extends State<AddRolePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roleNameController = TextEditingController();
  final TextEditingController _roleDescriptionController = TextEditingController();

  final List<String> _allPermissions = [
    'View Dashboard',
    'Manage Users',
    'Edit Roles',
    'View Orders',
    'Create Orders',
    'Delete Orders',
    'Access Reports',
    'Manage Billing',
  ];
  final Set<String> _selectedPermissions = {};

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final roleName = _roleNameController.text.trim();
      // Appel API pour ajouter le rôle
      try {
        final success = await RoleNetwork().addRole(
          roleName,
          _roleDescriptionController.text.trim(),
        );
        if (success) {
          Navigator.pop(context, {
            'name': roleName,
            'description': _roleDescriptionController.text.trim(),
            'permissions': _selectedPermissions.toList(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Role created successfully!"),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Failed to create role!"),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 10),
                Text("Erreur: $e"),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    _roleDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Role'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF8F2F5),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create a new role to assign specific permissions.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  // Role Name
                  RichText(
                    text: const TextSpan(
                      text: 'Role Name ',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _roleNameController,
                    decoration: InputDecoration(
                      hintText: "Enter role name",
                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Role name is required' : null,
                  ),
                  const SizedBox(height: 20),
                  // Description
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _roleDescriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Describe this role (optional)",
                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Permissions
                  const Text(
                    "Permissions",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedPermissions.clear();
                            _selectedPermissions.addAll(_allPermissions);
                          });
                        },
                        child: const Text("Select All"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedPermissions.clear();
                          });
                        },
                        child: const Text("Clear All"),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _allPermissions.map((perm) {
                      final isSelected = _selectedPermissions.contains(perm);
                      return FilterChip(
                        label: Text(perm),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPermissions.add(perm);
                            } else {
                              _selectedPermissions.remove(perm);
                            }
                          });
                        },
                        selectedColor: const Color(0xFF8C8CFF).withOpacity(0.2),
                        checkmarkColor: Colors.deepPurple,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel, color: Colors.black54),
                        label: const Text("Cancel", style: TextStyle(color: Colors.black54)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8C8CFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          elevation: 0,
                        ),
                        onPressed: _submit,
                        icon: const Icon(Icons.check),
                        label: const Text("Create Role"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
