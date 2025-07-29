import 'package:flutter/material.dart';
import 'package:flutter_application_1/network/role_network.dart';

class EditRolePage extends StatefulWidget {
  final String initialName;
  final int id;
  final String initialDescription;
  final List<String> initialPermissions;

  const EditRolePage({
    Key? key,
    required this.initialName,
    required this.initialDescription,
    required this.initialPermissions, required this.id,
  }) : super(key: key);

  @override
  State<EditRolePage> createState() => _EditRolePageState();
}

class _EditRolePageState extends State<EditRolePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roleNameController;
  late TextEditingController _roleDescriptionController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();
  bool _isLoading = false;

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
    // Focus sur le champ nom au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nameFocus);
    });
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    _roleDescriptionController.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final success = await RoleNetwork().updateRole(
        widget.id,
        widget.initialName, // oldRole (nom d'origine)
        _roleNameController.text.trim(), // newRole (nouveau nom)
        _roleDescriptionController.text.trim(),
        _selectedPermissions.toList(),
      );
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully!')),
        );
        Navigator.pop(context, {
          'id': widget.id,
          'name': _roleNameController.text.trim(),
          'description': _roleDescriptionController.text.trim(),
          'permissions': _selectedPermissions.toList(),
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update role!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, minHeight: 100),
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
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descFocus),
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
                    focusNode: _descFocus,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
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
                          backgroundColor: _isLoading ? Colors.grey : const Color(0xFF8C8CFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("Save Changes"),
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