import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:provider/provider.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Update your password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6F4DBF)),
              ),
              const SizedBox(height: 4),
              const Text(
                'For your security, please use a strong password that you do not use elsewhere.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildPasswordField(
                label: 'Current password',
                controller: _currentPasswordController,
                showPassword: _showCurrentPassword,
                onToggle: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'New password',
                controller: _newPasswordController,
                showPassword: _showNewPassword,
                onToggle: () => setState(() => _showNewPassword = !_showNewPassword),
                showInfo: true,
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'Confirm new password',
                controller: _confirmPasswordController,
                showPassword: _showConfirmPassword,
                onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF6F4DBF)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF6F4DBF), fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final currentPassword = _currentPasswordController.text.trim();
                        final newPassword = _newPasswordController.text.trim();
                        final confirmPassword = _confirmPasswordController.text.trim();
                        if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all fields')),
                          );
                          return;
                        }
                        if (newPassword != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New passwords do not match')),
                          );
                          return;
                        }
                        // Call controller
                        final userController = Provider.of<UserController>(context, listen: false);
                        String result = await userController.changePassword(
                          currentPassword: currentPassword,
                          newPassword: newPassword,
                          confirmPassword: confirmPassword,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: result.contains('success') ? Colors.green : Colors.red,
                            content: Text(result)),
                        );
                        if (result.contains('success')) {
                          // Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F4DBF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Update password', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggle,
    bool showInfo = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              obscureText: !showPassword,
              onSubmitted: label.toLowerCase().contains('confirm')
                  ? (_) async {
                      final currentPassword = _currentPasswordController.text.trim();
                      final newPassword = _newPasswordController.text.trim();
                      final confirmPassword = _confirmPasswordController.text.trim();
                      if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all fields')),
                        );
                        return;
                      }
                      if (newPassword != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New passwords do not match')),
                        );
                        return;
                      }
                      final userController = Provider.of<UserController>(context, listen: false);
                      String result = await userController.changePassword(
                        currentPassword: currentPassword,
                        newPassword: newPassword,
                        confirmPassword: confirmPassword,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: result.contains('success') ? Colors.green : Colors.red,
                          content: Text(result)),
                      );
                    }
                  : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF4F4F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showInfo)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.info_outline, color: Colors.grey[400]),
                      ),
                    IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[700],
                      ),
                      onPressed: onToggle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}