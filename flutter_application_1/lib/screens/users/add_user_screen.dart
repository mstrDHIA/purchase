import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';








class AddUserPage extends StatefulWidget {
  final String? email;
  final int? userId;
  const AddUserPage({super.key, this.email, this.userId});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  // Future<bool> _userExists(String username, String email) async {
  //   final users = await UserNetwork().uesresList();
  //   return users.any((u) => u.username == username || u.email == email);
  // }
  // final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // final _passwordController = TextEditingController();
  final String _selectedCountry = 'Tunisia';
  // String? _selectedRole = 'Member';

  final List<String> _countries = [
    'Tunisia', 'Poland', 'France', 'Germany', 'Spain',
    'Italy', 'USA', 'Canada', 'Morocco', 'Japan', 'China',
  ];

  File? _profileImage;
  String? _selectedAssetImage;

  @override
  void dispose() {
    // _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _pickProfileImageFromFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        _selectedAssetImage = null;
      });
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildLabeledBox(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(label),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       DrawerHeader(child: Text('Navigation')),
      //       ListTile(title: Text('Home'), onTap: () {}),
      //       ListTile(title: Text('Dashboard'), onTap: () {}),
      //       ListTile(title: Text('Users'), selected: true, selectedTileColor: Colors.grey[200], onTap: () {}),
      //       ListTile(title: Text('Password'), onTap: () {}),
      //       ListTile(title: Text('Request Order'), onTap: () {}),
      //       ListTile(title: Text('Purchase Order'), onTap: () {}),
      //       ListTile(title: Text('Roles and Access'), onTap: () {}),
      //       ListTile(title: Text('Support Centre'), onTap: () {}),
      //     ],
      //   ),
      // ),
      appBar: AppBar(
        title: Text(
          'User Information Form',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        foregroundColor: const Color.fromARGB(255, 23, 13, 220),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons
            // Row(
            //   children: [
            //     Expanded(child: SizedBox()),
            //     Column(
            //       children: [
//                     ElevatedButton(
//                       onPressed: () async {
//                         if (_usernameController.text.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('First Name is required')),
//                           );
//                           return;
//                         }

//                         // Vérification doublon username/email (ici username = firstName, email = '')
                        

//                         // 1. Créer l'utilisateur (User)
//                         // Créer le profil lié à cet utilisateur déjà créé (userId transmis)
//                         if (widget.userId == null) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text("Erreur : ID utilisateur manquant pour le profil.")),
//                           );
//                           return;
//                         }
                        
//                         // ScaffoldMessenger.of(context).showSnackBar(
//                         //   SnackBar(content: Text(message)),
//                         // );
//                         // Navigate to main screen after saving
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => MainScreen()),
//                         );
// // Dummy main screen, replace with your actual main page
// // class MainScreen extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Main Screen')),
// //       body: Center(child: Text('Welcome to the main screen!')),
// //     );
// //   }
// // }
//                       },
//                       child: Text('Save'),
//                     ),
                    SizedBox(height: 8),
                    
                    SizedBox(height: 8),
                   
            //       ],
            //     ),
            //   ],
            // ),
            SizedBox(height: 32),

            // Profile picture
            Center(
              child: Column(
                children: [
                  if (_profileImage != null)
                    Image.file(_profileImage!, width: 120, height: 120, fit: BoxFit.cover)
                  else if (_selectedAssetImage != null)
                    Image.asset(_selectedAssetImage!, width: 120, height: 120, fit: BoxFit.cover)
                  else
                    const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickProfileImageFromFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Open File to Select Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),


            const SizedBox(height: 60),

                      const Text(
                        'Username',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your username',
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        // obscureText: !_isPasswordVisible,
                        // onChanged: _checkPasswordStrength,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          // suffixIcon: IconButton(
                          //   icon: Icon(
                          //     _isPasswordVisible
                          //         ? Icons.visibility
                          //         : Icons.visibility_off,
                          //     color: Colors.grey,
                          //   ),
                          //   onPressed: () {
                          //     setState(() {
                          //       _isPasswordVisible = !_isPasswordVisible;
                          //     });
                          //   },
                          // ),
                          // errorText: _passwordError,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // if (_passwordStrength.isNotEmpty)
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       LinearProgressIndicator(
                      //         value: _passwordStrength == 'Weak'
                      //             ? 0.33
                      //             : _passwordStrength == 'Medium'
                      //                 ? 0.66
                      //                 : 1.0,
                      //         backgroundColor: Colors.grey.shade300,
                      //         valueColor:
                      //             AlwaysStoppedAnimation<Color>(_strengthColor),
                      //         minHeight: 8,
                      //       ),
                      //       const SizedBox(height: 6),
                      //       Text(
                      //         'Password strength: $_passwordStrength',
                      //         style: TextStyle(
                      //           color: _strengthColor,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       ),
                      //     ],
                      //   ),

                      const SizedBox(height: 24),

                      const Text(
                        'Confirm Password',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Re-enter your password',
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          // errorText: _confirmPasswordError,
                        ),
                      ),
                      const SizedBox(height: 24),


                      Consumer<UserController>(
                        builder: (context, userController, child) {
                          return ElevatedButton(onPressed: (){
                            if (_usernameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Username is required')),
                              );
                              return;
                            }
                            if (_passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password is required')),
                              );
                              return;
                            }
                            if (_confirmPasswordController.text != _passwordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match')),
                              );
                              return;
                            }
                            userController.addUser(_usernameController.text, _passwordController.text, context);
                          
                                               
                            
                          }, child: Text('Save'));
                        }
                      ),

            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildLabeledBox(
            //         'First Name',
            //         TextField(
            //           controller: _firstNameController,
            //           decoration: const InputDecoration(hintText: 'Enter first name'),
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 16),
            //     Expanded(
            //       child: _buildLabeledBox(
            //         'Last Name',
            //         TextField(
            //           controller: _lastNameController,
            //           decoration: const InputDecoration(hintText: 'Enter last name'),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: 24),



            // _buildLabeledBox(
            //   'Address',
            //   TextField(controller: _addressController),
            // ),
            // SizedBox(height: 24),

            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildLabeledBox(
            //         'City',
            //         TextField(controller: _cityController),
            //       ),
            //     ),
            //     SizedBox(width: 16),
            //     Expanded(
            //       child: _buildLabeledBox(
            //         'State',
            //         TextField(controller: _stateController),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: 24),

            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildLabeledBox(
            //         'ZIP',
            //         TextField(controller: _zipController),
            //       ),
            //     ),
            //     SizedBox(width: 16),
            //     Expanded(
            //       child: _buildLabeledBox(
            //         'Country',
            //         DropdownButtonFormField<String>(
            //           value: _selectedCountry,
            //           onChanged: (value) {
            //             setState(() {
            //               _selectedCountry = value!;
            //             });
            //           },
            //           items: _countries.map((country) => DropdownMenuItem(
            //             value: country,
            //             child: Text(country),
            //           )).toList(),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
