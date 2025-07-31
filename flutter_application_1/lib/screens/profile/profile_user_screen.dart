import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_application_1/network/profile_network.dart';
import 'package:flutter_application_1/screens/Purchase%20order/purchase_form_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart'; // Add this import at the top if not present
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// Assuming '../auth/login.dart' points to your login page
import '../auth/login_screen.dart'; 


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/profile.dart';
// import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:image_picker/image_picker.dart';


class Profileuserpage extends StatelessWidget {
  final Profile profile;
  const Profileuserpage({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: ${profile.firstName ?? "-"}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            Text('Last Name: ${profile.lastName ?? "-"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Bio: ${profile.bio ?? "-"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Location: ${profile.location ?? "-"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Country: ${profile.country ?? "-"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('State: ${profile.state ?? "-"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('City: ${profile.city ?? "-"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Zip Code: ${profile.zipCode?.toString() ?? "-"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Address: ${profile.address ?? "-"}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isProfileLoading = false;
  // Add FocusNodes for better keyboard navigation and focus management
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _usernameSuffixFocusNode = FocusNode();

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernamePrefixController;
  late TextEditingController _usernameSuffixController;
  late TextEditingController _roleController;

  // Add available roles
  final List<String> _roles = ['Member', 'Admin', 'Editor', 'Viewer'];

  File? _profileImageFile;

  bool isEditing = false; // Add this variable

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lastNameController = TextEditingController(text: widget.user["profile_id"]["last_name"]?.toString() ?? "");
    _emailController = TextEditingController(text: widget.user["email"]?.toString() ?? "");
    _usernamePrefixController = TextEditingController(text: "untitledui.com/");
    _usernameSuffixController = TextEditingController(text: widget.user["username"]?.toString() ?? "");
    _roleController = TextEditingController(text: widget.user["role"]?.toString() ?? "Member");

    // Récupère le first_name et last_name depuis le profile si profile_id existe
    final profileId = widget.user["profile_id"];
    if (profileId != null) {
      setState(() {
        _isProfileLoading = true;
      });
      _fetchProfileNames(profileId);
    } else {
      _nameController.text = widget.user["first_name"]?.toString() ?? "";
      _lastNameController.text = widget.user["last_name"]?.toString() ?? "";
    }
  }

  Future<void> _fetchProfileNames(dynamic profileId) async {
    int? pid;
    if (profileId is int) {
      pid = profileId;
    } else if (profileId is String) {
      pid = int.tryParse(profileId);
    }
    if (pid == null) return;
    try {
      // Remplace par ton appel réseau réel pour récupérer le profil
      final profile = await ProfileNetwork().viewProfile(pid);
      if (profile != null) {
        setState(() {
          _nameController.text = profile.firstName ?? "";
          _lastNameController.text = profile.lastName ?? "";
          _isProfileLoading = false;
        });
      } else {
        setState(() {
          _isProfileLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération du profil: $e");
      setState(() {
        _isProfileLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernamePrefixController.dispose();
    _usernameSuffixController.dispose();
    _roleController.dispose();

    // Dispose FocusNodes
    _nameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _usernameSuffixFocusNode.dispose();

    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _profileImageFile = File(picked.path);
        });
      }
    } catch (e) {
      // Handle potential errors like permission denied
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // A helper function to show snackbars
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Shorter duration for quick feedback
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = widget.user["profile_id"] != null;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Row(
              children: [
                GestureDetector(
                  onTap: isEditing ? _pickProfileImage : null, // Only allow change if editing
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!) as ImageProvider<Object>?
                        : null,
                    child: _profileImageFile == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isProfileLoading
                        ? SizedBox(
                            width: 180,
                            child: LinearProgressIndicator(minHeight: 2),
                          )
                        : Text(
                            '${_nameController.text} ${_lastNameController.text}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                          ),
                    Text(
                      _emailController.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (!hasProfile)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        
                      ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final String currentUsername = _usernameSuffixController.text.isNotEmpty
                        ? _usernameSuffixController.text
                        : 'user';
                    final profileUrl = 'https://${_usernamePrefixController.text}$currentUsername';
                    await Clipboard.setData(ClipboardData(text: profileUrl));
                    _showSnackBar('Profile link copied: $profileUrl');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[50],
                    foregroundColor: Colors.deepPurple[700],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Copy link'),
                ),
                const SizedBox(width: 12),
                
                OutlinedButton.icon(
                  onPressed: () async {
                    if (isEditing) {
                      
                      dynamic idValue = widget.user["id"];
                      int? userId;
                      if (idValue is int) {
                        userId = idValue;
                      } else if (idValue is String) {
                        userId = int.tryParse(idValue);
                      } else {
                        userId = null;
                      }
                      if (userId == null || userId == 0) {
                        _showSnackBar("ID utilisateur invalide.");
                        return;
                      }
                      print("ID reçu dans widget.user: $idValue");
                      // Prépare les données à envoyer
                      final data = {
                        "first_name": _nameController.text,
                        "last_name": _lastNameController.text,
                        "email": _emailController.text,
                        "username": _usernameSuffixController.text,
                        "role": _roleController.text,
                      };
                      // Appel API
                      final result = await ProfileNetwork().updateProfile(
                        Profile.fromJson(data),
                        userId,
                      );
                      _showSnackBar(result);
                      setState(() {
                        isEditing = false;
                      });
                    } else {
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
                  icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.deepPurple),
                  label: Text(isEditing ? 'Save' : 'Edit', style: const TextStyle(color: Colors.deepPurple)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    overlayColor: Colors.deepPurple.withOpacity(0.05),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Form Fields
            // First name
            Text(
              'First name',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 8),
            _buildGreyTextField(
              _nameController,
              focusNode: _nameFocusNode,
              hintText: 'Prénom',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              enabled: isEditing,
            ),
            const SizedBox(height: 24),

            // Last name
            Text(
              'Last name',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 8),
            _buildGreyTextField(
              _lastNameController,
              focusNode: _lastNameFocusNode,
              hintText: 'Nom',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              enabled: isEditing,
            ),
            const SizedBox(height: 24),
            _buildEmailField(context, _emailController, _emailFocusNode, enabled: isEditing),
            const SizedBox(height: 24),
            _buildUsernameField(context, _usernamePrefixController, _usernameSuffixController, _usernameSuffixFocusNode, enabled: isEditing),
            const SizedBox(height: 24),
            _buildRoleField(context, _roleController, enabled: isEditing),
            const SizedBox(height: 24),
            _buildProfilePhotoField(context, enabled: isEditing),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Log out?'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => SignInPage()),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Log out'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.deepPurple),
                  label: const Text('Log out', style: TextStyle(color: Colors.deepPurple)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    overlayColor: Colors.deepPurple.withOpacity(0.05),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldRow(
    BuildContext context, {
    required String labelText,
    required TextEditingController controller1,
    required TextEditingController controller2,
    FocusNode? focusNode1,
    FocusNode? focusNode2,
    String? hintText1,
    String? hintText2,
    bool enabled = false, // Add enabled parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreyTextField(
                    controller1,
                    focusNode: focusNode1,
                    hintText: hintText1,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => focusNode2?.requestFocus(),
                    enabled: enabled, // Pass enabled
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGreyTextField(
                controller2,
                focusNode: focusNode2,
                hintText: hintText2,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                enabled: enabled, // Pass enabled
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, TextEditingController controller, FocusNode focusNode, {bool enabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email address',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        _buildGreyTextField(
          controller,
          focusNode: focusNode,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          hintText: 'your.email@example.com',
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          enabled: enabled, // Pass enabled
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context, TextEditingController prefixController, TextEditingController suffixController, FocusNode suffixFocusNode, {bool enabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              prefixController.text,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildGreyTextField(
                suffixController,
                focusNode: suffixFocusNode,
                suffixIcon: Icons.edit,
                hintText: 'your_username',
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.none,
                enabled: enabled, // Pass enabled
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleField(BuildContext context, TextEditingController controller, {bool enabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: controller.text,
            items: _roles
                .map((role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    ))
                .toList(),
            onChanged: enabled
                ? (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        controller.text = newValue;
                      });
                    }
                  }
                : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
            disabledHint: Text(controller.text),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoField(BuildContext context, {bool enabled = false}) {
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
            GestureDetector(
              onTap: enabled ? _pickProfileImage : null,
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey[300],
                backgroundImage: _profileImageFile != null
                    ? FileImage(_profileImageFile!) as ImageProvider<Object>?
                    : null,
                child: _profileImageFile == null
                    ? const Icon(Icons.person, size: 32, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: enabled ? _pickProfileImage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                overlayColor: Colors.grey[50],
              ),
              child: const Text('Click to replace'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreyTextField(
    TextEditingController controller, {
    FocusNode? focusNode,
    IconData? icon,
    IconData? suffixIcon,
    bool readOnly = false,
    bool enabled = false, // Add enabled parameter
    TextInputType? keyboardType,
    String? hintText,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: !enabled, // Only editable if enabled
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      textCapitalization: textCapitalization,
    );
  }
}