import 'package:flutter/material.dart';

class EditRolePage extends StatefulWidget {
  final String initialName;
  final String initialDescription;
  final List<String> initialPermissions;

  const EditRolePage({
    Key? key,
    required this.initialName,
    required this.initialDescription,
    required this.initialPermissions,
  }) : super(key: key);

  @override
  State<EditRolePage> createState() => _EditRolePageState();
}

class _EditRolePageState extends State<EditRolePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roleNameController;
  late TextEditingController _roleDescriptionController;

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
  late Set<String> _selectedPermissions;

  @override
  void initState() {
    super.initState();
    _roleNameController = TextEditingController(text: widget.initialName);
    _roleDescriptionController = TextEditingController(text: widget.initialDescription);
    _selectedPermissions = widget.initialPermissions.toSet();
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    _roleDescriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Save logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.deepPurple, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Edit Role',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[700],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  "Role Name",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                const Text(
                  "Permissions",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ..._allPermissions.map((perm) => CheckboxListTile(
                      value: _selectedPermissions.contains(perm),
                      title: Text(perm),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedPermissions.add(perm);
                          } else {
                            _selectedPermissions.remove(perm);
                          }
                        });
                      },
                    )),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C8CFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      child: const Text("Save Changes"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}