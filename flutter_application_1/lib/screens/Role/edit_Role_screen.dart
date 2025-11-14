import 'package:flutter/material.dart';

class EditRolePage extends StatefulWidget {
  final String initialName;
  final int id;
  final String initialDescription;

  const EditRolePage({
    super.key,
    required this.initialName,
    required this.initialDescription,
     required this.id,
  });

  @override
  State<EditRolePage> createState() => _EditRolePageState();
}

class _EditRolePageState extends State<EditRolePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roleNameController;
  late TextEditingController _roleDescriptionController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _roleNameController = TextEditingController(text: widget.initialName);
    _roleDescriptionController = TextEditingController(text: widget.initialDescription);
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.4,
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
                        backgroundColor:  const Color(0xFF8C8CFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        elevation: 0,
                      ),
                      onPressed:  _submit,
                      child:const Text("Save Changes"),
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