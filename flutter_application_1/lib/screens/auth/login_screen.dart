import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart'; // Importez le UserController ici

import 'package:flutter_application_1/screens/auth/forget_password_screen.dart';

import 'package:flutter_application_1/screens/auth/signup_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; // Importez Provider ici

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  // String _selectedRole = 'Utilisateur'; 
  late UserController userController ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
  }

  emailValidator(String? value) {
    // if (value == null || value.isEmpty || !value.contains('@')) {
    //   return 'Please enter a valid email.';
    // }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (constraints.maxWidth > 800)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Capture.PNG'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Get Started',
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const SignUpPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text("Email"),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _emailController,
                              hintText: "abc123@gmail.com",
                              // validator: (value) {
                              //  return emailValidator(value);
                              // },
                            ),
                            const SizedBox(height: 16),
                            const Text("Password"),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: "Enter your password",
                                filled: true,
                                fillColor: Colors.blue[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Password is required.';
                              //   }

                              //   final password = value.trim();

                              //   if (password.length < 8) {
                              //     return 'Password must be at least 8 characters long.';
                              //   }

                              //   if (!RegExp(r'[A-Z]').hasMatch(password)) {
                              //     return 'Include at least one uppercase letter.';
                              //   }

                              //   if (!RegExp(r'[a-z]').hasMatch(password)) {
                              //     return 'Include at least one lowercase letter.';
                              //   }

                              //   if (!RegExp(r'[0-9]').hasMatch(password)) {
                              //     return 'Include at least one number.';
                              //   }

                              //   if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
                              //     return 'Include at least one special character.';
                              //   }

                              //   return null;
                              // },
                              onFieldSubmitted: (_) {
                                // if (_formKey.currentState!.validate()) {
                                  userController.login(
                                  _emailController.text,
                                  _passwordController.text,
                                  context,
                                  _formKey
                                );
                                // }
                                
                              },
                            ),
                            
                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ForgetPasswordPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Forget password?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Consumer<UserController>(
                              builder: (context, userController, child) {
                                if (userController.isLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                else{
                                  return ElevatedButton(
                                  onPressed: () {
                                    userController.login(
                                      _emailController.text,
                                      _passwordController.text,
                                      context,
                                      _formKey
                                    );
                                  },
                                  child: SizedBox(
                                 
                                    height: 40,
                                    width: double.infinity,
                                    child: Center(child: const Text('Login'))),
                                );
                                }
                                
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Page')),
      body: const Center(child: Text('Welcome to the Main Page!')),
    );
  }
}

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: const Center(child: Text('Log In Page')),
    );
  }
}
