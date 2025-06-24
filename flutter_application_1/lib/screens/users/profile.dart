import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_application_1/screens/Purchase%20order/Purchase_form.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// Assuming '../auth/login.dart' points to your login page
import '../auth/login.dart'; // Make sure this path is correct

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Changed to a more consistent purple theme
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        // Define text selection theme for a better user experience
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.deepPurple, // Custom cursor color
          selectionColor: Colors.deepPurple.withOpacity(0.3), // Custom selection highlight color
          selectionHandleColor: Colors.deepPurple, // Custom selection handles
        ),
        inputDecorationTheme: InputDecorationTheme(
          // Apply consistent styling to all text fields
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0), // Thicker, purple border on focus
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2.0), // Clear error indication
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: Colors.grey[700]), // Style for floating labels
          hintStyle: TextStyle(color: Colors.grey[500]), // Style for hints
        ),
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Add FocusNodes for better keyboard navigation and focus management
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _usernameSuffixFocusNode = FocusNode();

  final TextEditingController _nameController = TextEditingController(text: 'Amélie');
  final TextEditingController _lastNameController = TextEditingController(text: 'Laurent');
  final TextEditingController _emailController = TextEditingController(text: 'Amélie@untitleddui.com');
  final TextEditingController _usernamePrefixController = TextEditingController(text: 'untitledui.com/');
  final TextEditingController _usernameSuffixController = TextEditingController(text: 'amelie');
  final TextEditingController _roleController = TextEditingController(text: 'Member'); // Consider making this a Dropdown or static text

  // Add available roles
  final List<String> _roles = ['Member', 'Admin', 'Editor', 'Viewer'];

  File? _profileImageFile;

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Back', // UX: Add tooltip for accessibility
        ),
        actions: const [
          // If a profile icon is needed here, re-add it. The image implies it's in the top right.
          // For now, aligning with the image, which doesn't show a distinct profile icon there.
          SizedBox(width: 16), // Keep some spacing if no icon is present
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Row(
              children: [
                GestureDetector( // UX: Make profile image tappable to change
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!) as ImageProvider<Object>?
                        : null, // Cast to ImageProvider<Object>?
                    child: _profileImageFile == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amélie Laurent', // Consider using controllers for dynamic update
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                    Text(
                      'Amélie@untitleddui.com', // Consider using controllers for dynamic update
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    // Using current email/username for the dynamic link if needed
                    final String currentUsername = _usernameSuffixController.text.isNotEmpty
                        ? _usernameSuffixController.text
                        : 'user'; // Fallback if username is empty
                    final profileUrl = 'https://${_usernamePrefixController.text}$currentUsername';
                    await Clipboard.setData(ClipboardData(text: profileUrl));
                    _showSnackBar('Profile link copied: $profileUrl'); // UX: Dynamic message
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[50],
                    foregroundColor: Colors.deepPurple[700],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    // UX: Add a slight hover effect or visual feedback
                    shadowColor: Colors.transparent, // Remove default shadow
                  ),
                  child: const Text('Copy link'), // UX: English text
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Form Fields
            _buildTextFieldRow(
              context,
              labelText: 'Name', // UX: English label
              controller1: _nameController,
              controller2: _lastNameController,
              focusNode1: _nameFocusNode,
              focusNode2: _lastNameFocusNode,
              hintText1: 'Amélie', // UX: Hint text
              hintText2: 'Laurent', // UX: Hint text
            ),
            const SizedBox(height: 24),
            _buildEmailField(context, _emailController, _emailFocusNode),
            const SizedBox(height: 24),
            _buildUsernameField(context, _usernamePrefixController, _usernameSuffixController, _usernameSuffixFocusNode),
            const SizedBox(height: 24),
            _buildRoleField(context, _roleController),
            const SizedBox(height: 24),
            _buildProfilePhotoField(context),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // UX: Confirmation dialog before logging out
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Log out?'), // English
                          content: const Text('Are you sure you want to log out?'), // English
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Dismiss dialog
                              },
                              child: const Text('Cancel'), // English
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Dismiss dialog
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => SignInPage()),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Red for logout confirmation
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Log out'), // English
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.deepPurple),
                  label: const Text('Log out', style: TextStyle(color: Colors.deepPurple)), // UX: English text
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // UX: Slight hover effect or improved feedback
                    overlayColor: Colors.deepPurple.withOpacity(0.05),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => PurchaseOrderForm(
                          onSave: (order) {
                            // TODO: Implement save logic or navigation after saving
                          },
                          initialOrder: {}, // TODO: Replace with an actual initial order if needed
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    overlayColor: Colors.grey[200], 
                  ),
                  child: const Text('Cancel'), 
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Basic validation example
                    if (_nameController.text.isEmpty || _lastNameController.text.isEmpty || _emailController.text.isEmpty) {
                      _showSnackBar('Please fill in all required fields.'); // English
                      // UX: Also highlight specific fields with errors, could set errorText in InputDecoration
                      return;
                    }
                    _showSnackBar('Changes saved!'); // UX: Feedback
                    // Here you would typically send data to a backend or update local state
                    // e.g., print(_nameController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color for main action
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    shadowColor: Colors.deepPurple[100], // Slight shadow for emphasis
                  ),
                  child: const Text('Save changes'), // UX: English text
                ),
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
              child: _buildGreyTextField(
                controller1,
                focusNode: focusNode1,
                hintText: hintText1,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => focusNode2?.requestFocus(),
                // Only allow letters and spaces for name fields
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
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, TextEditingController controller, FocusNode focusNode) {
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
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context, TextEditingController prefixController, TextEditingController suffixController, FocusNode suffixFocusNode) {
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
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleField(BuildContext context, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role', // UX: English label
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
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  controller.text = newValue;
                });
              }
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile photo', // UX: English label
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector( // UX: Make avatar tappable for image change
              onTap: _pickProfileImage,
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
              onPressed: _pickProfileImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                overlayColor: Colors.grey[50], // UX: Visual feedback on press
              ),
              child: const Text('Click to replace'), // UX: English text
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreyTextField(
    TextEditingController controller, {
    FocusNode? focusNode, // Added FocusNode parameter
    IconData? icon,
    IconData? suffixIcon,
    bool readOnly = false,
    TextInputType? keyboardType, // Added keyboardType
    String? hintText, // Added hintText
    TextInputAction? textInputAction, // Added textInputAction
    Function(String)? onSubmitted, // Added onSubmitted
    TextCapitalization textCapitalization = TextCapitalization.none, // Added textCapitalization
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode, // Assign FocusNode
      readOnly: readOnly,
      keyboardType: keyboardType, // Assign keyboardType
      textInputAction: textInputAction, // Assign textInputAction
      onSubmitted: onSubmitted, // Assign onSubmitted
      textCapitalization: textCapitalization, // Assign textCapitalization
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey[600]) : null,
        hintText: hintText, // Assign hintText
        // The rest of the decoration is now handled by the InputDecorationTheme in ThemeData
      ),
      style: TextStyle(color: Colors.grey[800]),
    );
  }
}