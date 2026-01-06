import 'package:flutter/material.dart';

class AddSupplierPage extends StatefulWidget {
  const AddSupplierPage({super.key});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddSupplierDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Add New Supplier'),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, 'Name', validator: _notEmptyValidator),
                  const SizedBox(height: 16),
                  _buildTextField(emailController, 'Email', validator: _validateEmail),
                  const SizedBox(height: 16),
                  _buildTextField(phoneController, 'Phone Number'),
                  const SizedBox(height: 16),
                  _buildTextField(codeController, 'Code fournisseur'),
                  const SizedBox(height: 16),
                  _buildTextField(addressController, 'Address'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final supplierData = {
                              'name': nameController.text,
                              'contact_email': emailController.text,
                              'phone_number': phoneController.text.isEmpty ? null : phoneController.text,
                              'code_fournisseur': codeController.text.isEmpty ? null : codeController.text,
                              'address': addressController.text.isEmpty ? null : addressController.text,
                            };
                            Navigator.of(context).pop(supplierData);
                            Navigator.of(context).pop(supplierData);
                          }
                        },
                        child: const Text('Save'),
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
  
  Widget _buildTextField(TextEditingController controller, String label, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? _notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
