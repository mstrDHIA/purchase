
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required Map<String, String> user, Profile? profile});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final FocusNode _nameFocusNode = FocusNode();
//   final FocusNode _lastNameFocusNode = FocusNode();
//   final FocusNode _emailFocusNode = FocusNode();
//   final FocusNode _usernameSuffixFocusNode = FocusNode();

//   final TextEditingController _nameController = TextEditingController(text: 'Amélie');
//   final TextEditingController _lastNameController = TextEditingController(text: 'Laurent');
//   final TextEditingController _emailController = TextEditingController(text: 'Amélie@untitleddui.com');
//   final TextEditingController _usernamePrefixController = TextEditingController(text: 'untitledui.com/');
//   final TextEditingController _usernameSuffixController = TextEditingController(text: 'amelie');
//   final TextEditingController _roleController = TextEditingController(text: 'Member');

//   final List<String> _roles = ['Member', 'Admin', 'Editor', 'Viewer'];
//   File? _profileImageFile;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _usernamePrefixController.dispose();
//     _usernameSuffixController.dispose();
//     _roleController.dispose();
//     _nameFocusNode.dispose();
//     _lastNameFocusNode.dispose();
//     _emailFocusNode.dispose();
//     _usernameSuffixFocusNode.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F2F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//           tooltip: 'Back',
//         ),
//         title: const Text(
//           'Profile',
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 500),
//             padding: const EdgeInsets.all(28),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.08),
//                   blurRadius: 16,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Avatar & Name
//                 Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 48,
//                       backgroundColor: Colors.deepPurple[100],
//                       backgroundImage: _profileImageFile != null
//                           ? FileImage(_profileImageFile!)
//                           : null,
//                       child: _profileImageFile == null
//                           ? const Icon(Icons.person, size: 48, color: Colors.white)
//                           : null,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       '${_nameController.text} ${_lastNameController.text}',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _emailController.text,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 // Profile link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.link, color: Colors.deepPurple[300], size: 20),
//                     const SizedBox(width: 6),
//                     Flexible(
//                       child: Text(
//                         'https://${_usernamePrefixController.text}${_usernameSuffixController.text}',
//                         style: const TextStyle(
//                           color: Colors.deepPurple,
//                           fontSize: 15,
//                           decoration: TextDecoration.underline,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.copy, size: 20, color: Colors.deepPurple),
//                       tooltip: 'Copy profile link',
//                       onPressed: () async {
//                         final profileUrl = 'https://${_usernamePrefixController.text}${_usernameSuffixController.text}';
//                         await Clipboard.setData(ClipboardData(text: profileUrl));
//                         _showSnackBar('Profile link copied!');
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 // Info fields
//                 _buildReadOnlyField(context, label: 'First Name', controller: _nameController),
//                 const SizedBox(height: 16),
//                 _buildReadOnlyField(context, label: 'Last Name', controller: _lastNameController),
//                 const SizedBox(height: 16),
//                 _buildReadOnlyField(context, label: 'Email', controller: _emailController, icon: Icons.email_outlined),
//                 const SizedBox(height: 16),
//                 _buildReadOnlyField(context, label: 'Username', controller: _usernameSuffixController, prefix: _usernamePrefixController.text),
//                 const SizedBox(height: 16),
//                 _buildReadOnlyDropdown(context, label: 'Role', value: _roleController.text, items: _roles),
//                 const SizedBox(height: 32),
//                 // Close button
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton.icon(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close, color: Colors.deepPurple),
//                     label: const Text(
//                       "Close",
//                       style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReadOnlyField(BuildContext context,
//       {required String label, required TextEditingController controller, IconData? icon, String? prefix}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           controller: controller,
//           readOnly: true,
//           decoration: InputDecoration(
//             prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple[200]) : null,
//             prefixText: prefix,
//             prefixStyle: const TextStyle(color: Colors.black54),
//             filled: true,
//             fillColor: const Color(0xFFF4F4F4),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           ),
//           style: const TextStyle(color: Colors.black87, fontSize: 16),
//         ),
//       ],
//     );
//   }

//   Widget _buildReadOnlyDropdown(BuildContext context,
//       {required String label, required String value, required List<String> items}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//         ),
//         const SizedBox(height: 6),
//         IgnorePointer(
//           child: DropdownButtonFormField<String>(
//             value: value,
//             items: items
//                 .map((role) => DropdownMenuItem<String>(
//                       value: role,
//                       child: Text(role),
//                     ))
//                 .toList(),
//             onChanged: null,
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xFFF4F4F4),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             ),
//             icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
//           ),
//         ),
//       ],
//     );
//   }
// }