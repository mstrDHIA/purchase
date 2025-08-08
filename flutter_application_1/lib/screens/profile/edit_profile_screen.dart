import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_application_1/controllers/user_controller.dart';
// Add this import at the top if not present
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
// Assuming '../auth/login.dart' points to your login page
import '../auth/login_screen.dart'; 



// import 'package:flutter_application_1/screens/auth/login.dart';


// class Profileuserpage extends StatelessWidget {
//   final Profile profile;
//   const Profileuserpage({Key? key, required this.profile}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('First Name: ${profile.firstName ?? "-"}', style: const TextStyle(fontSize: 20)),
//             const SizedBox(height: 12),
//             Text('Last Name: ${profile.lastName ?? "-"}', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 12),
//             Text('Bio: ${profile.bio ?? "-"}', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 12),
//             Text('Location: ${profile.location ?? "-"}', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 12),
//             Text('Country: ${profile.country ?? "-"}', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 12),
//             Text('State: ${profile.state ?? "-"}', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 12),
//             Text('City: ${profile.city ?? "-"}', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 12),
//             Text('Zip Code: ${profile.zipCode?.toString() ?? "-"}', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 12),
//             Text('Address: ${profile.address ?? "-"}', style: const TextStyle(fontSize: 18)),
//           ],
//         ),
//       ),
//     );
//   }
// }

class EditProfileScreen extends StatefulWidget {
  // final Map<String, dynamic> user;
  // final int userId;
  const EditProfileScreen({super.key, });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // final bool _isProfileLoading = false;
  // Add FocusNodes for better keyboard navigation and focus management
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _usernameSuffixFocusNode = FocusNode();

  late TextEditingController _nameController;
  // late TextEditingController _lastNameController;
  // late TextEditingController _emailController;
  // // late TextEditingController _usernamePrefixController;
  // late TextEditingController _usernameController;
  // late TextEditingController _roleController;

  // Add available roles
  // final List<String> _roles = ['Member', 'Admin', 'Editor', 'Viewer'];

  File? _profileImageFile;

  

  bool isEditing = false; // Add this variable
  late UserController userController;

  @override
  void initState() {
    userController=Provider.of<UserController>(context, listen: false);

    super.initState();

  }



  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    print('id: ${userController.selectedUserId}');

  }
  @override
  void dispose() {
    _nameController.dispose();

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.deepPurple[700],
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.white,
      body: Consumer<UserController>(
        builder: (context,userController, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

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

                              Text(userController.selectedUser.username ?? 'Username not set',),

                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {

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

                FieldWidget(txt: userController.selectedUser.username??"Username is not set",field: 'Username'),
                const SizedBox(height: 24),
                FieldWidget(txt: userController.selectedUser.email??"Email is not set",field: 'Email'),
                const SizedBox(height: 24),
                Divider(),
                const SizedBox(height: 24),

                Text("Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[700],
                ),
                ),
                const SizedBox(height: 24),
                if(userController.selectedUser.profile != null)
                Column(
                  children: [
                    FieldWidget(txt: userController.selectedUser.profile!.firstName??"First name is not set",field: 'First name'),
                    const SizedBox(height: 24),
                FieldWidget(txt: userController.selectedUser.profile!.lastName??"Last name is not set",field: 'Last name'),
                const SizedBox(height: 24),
                FieldWidget(txt: userController.selectedUser.profile!.country??"Country is not set",field: 'Country'),
                const SizedBox(height: 24),
                FieldWidget(txt: userController.selectedUser.profile!.state??"State is not set",field: 'State'),
                const SizedBox(height: 24),
                FieldWidget(txt: userController.selectedUser.profile!.city??"City is not set",field: 'City'),
                const SizedBox(height: 24),
                FieldWidget(txt: userController.selectedUser.profile!.address??"Address is not set",field: 'Address'),
                const SizedBox(height: 24),
                FieldWidget(txt: userController.selectedUser.profile!.location??"Location is not set",field: 'Location'),
                const SizedBox(height: 24),
                FieldWidget(txt: userController.selectedUser.profile!.zipCode.toString(),field: 'Zip Code'),
                
                  ],
                ),
                if(userController.selectedUser.profile == null)
                  Column(
                  children: const [
                    FieldWidget(txt: "First name is not set",field: 'First name'),
                    SizedBox(height: 24),
                FieldWidget(txt: "Last name is not set",field: 'Last name'),
                SizedBox(height: 24),
                FieldWidget(txt:"Country is not set",field: 'Country'),
                SizedBox(height: 24),
                FieldWidget(txt:"State is not set",field: 'State'),
                SizedBox(height: 24),
                FieldWidget(txt: "City is not set",field: 'City'),
                SizedBox(height: 24),
                FieldWidget(txt:"Address is not set",field: 'Address'),
                SizedBox(height: 24),
                FieldWidget(txt: "Location is not set",field: 'Location'),
                SizedBox(height: 24),
                FieldWidget(txt: "Zip Code is not set",field: 'Zip Code'),
                  ],
                ),
                const SizedBox(height: 32),
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
          );
        }
      ),
    );
  }
}

class FieldWidget extends StatelessWidget {
  final String txt;
  final String field;
  // final double width;
   const FieldWidget({
    super.key, required this.txt, required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
                  field,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 8),
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(txt ),
              ),
            ],
          )),
      ],
    );
  }
}