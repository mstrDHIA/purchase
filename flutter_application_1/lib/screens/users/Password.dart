import 'package:flutter/material.dart';
import 'package:flutter_application_1/network/change_password.dart';
import 'package:flutter_application_1/models/change_password.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final FocusNode _currentFocus = FocusNode();
  final FocusNode _newFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  String? _newPasswordMessage;
  Color _newPasswordMessageColor = Colors.red;

  void _validateNewPassword(String value) {
    setState(() {
      if (value.length < 8) {
        _newPasswordMessage = 'Your password must be at least 8 characters';
        _newPasswordMessageColor = Colors.red;
      } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
        _newPasswordMessage = 'Include at least one uppercase letter';
        _newPasswordMessageColor = Colors.red;
      } else if (!RegExp(r'[0-9]').hasMatch(value)) {
        _newPasswordMessage = 'Include at least one number';
        _newPasswordMessageColor = Colors.red;
      } else if (!RegExp(r'[!@#\$&*~_\-.,;:?%^+=]').hasMatch(value)) {
        _newPasswordMessage = 'Include at least one special character';
        _newPasswordMessageColor = Colors.red;
      } else {
        _newPasswordMessage = 'Strong password';
        _newPasswordMessageColor = Colors.green;
      }
    });
  }

  bool _isFormDirty() {
    return _currentController.text.isNotEmpty ||
        _newController.text.isNotEmpty ||
        _confirmController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _currentFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Change Password',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        centerTitle: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.of(context).maybePop(),
        //   tooltip: 'Back',
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update your password',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6F4DBF)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'For your security, please use a strong password that you do not use elsewhere.',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      const SizedBox(height: 32),
                      _buildPasswordField(
                        label: 'Current password',
                        controller: _currentController,
                        focusNode: _currentFocus,
                        obscure: _obscureCurrent,
                        onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        validator: (value) => value == null || value.isEmpty ? 'Enter current password' : null,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_newFocus),
                      ),
                      const SizedBox(height: 24),
                      _buildPasswordField(
                        label: 'New password',
                        controller: _newController,
                        focusNode: _newFocus,
                        obscure: _obscureNew,
                        onToggle: () => setState(() => _obscureNew = !_obscureNew),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Include at least one uppercase letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Include at least one number';
                          }
                          if (!RegExp(r'[!@#\$&*~_\-.,;:?%^+=]').hasMatch(value)) {
                            return 'Include at least one special character';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmFocus),
                        onChanged: _validateNewPassword,
                        infoTooltip: 'At least 8 chars, 1 uppercase, 1 number, 1 special character',
                      ),
                      if (_newPasswordMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4),
                          child: Text(
                            _newPasswordMessage!,
                            style: TextStyle(color: _newPasswordMessageColor, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 24),
                      _buildPasswordField(
                        label: 'Confirm new password',
                        controller: _confirmController,
                        focusNode: _confirmFocus,
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) =>
                            value != _newController.text ? 'Passwords do not match' : null,
                        onFieldSubmitted: (_) {},
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Color(0xFFB7A6F7)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8C8CFF),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: !_isFormDirty() || _loading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        setState(() => _loading = true);
                                        final success = await ChangePasswordNetwork(api: null).updatePassword(
                                          ChangePasswordRequest(
                                            oldPassword: _currentController.text,
                                            newPassword: _newController.text,
                                          ),
                                          // Provide the second required argument here, e.g., a context or userId as needed
                                          context, // <-- Replace with the correct argument type if not context
                                        );
                                        setState(() => _loading = false);
                                        if (success) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Success'),
                                              content: const Text('Your password has been updated.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Password update failed!')),
                                          );
                                        }
                                      }
                                    },
                              child: _loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Update password', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    required void Function(String) onFieldSubmitted,
    void Function(String)? onChanged,
    String? infoTooltip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (infoTooltip != null)
                  Tooltip(
                    message: infoTooltip,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.info_outline, size: 20, color: Colors.grey),
                    ),
                  ),
                IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: onToggle,
                  tooltip: obscure ? 'Show password' : 'Hide password',
                ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
