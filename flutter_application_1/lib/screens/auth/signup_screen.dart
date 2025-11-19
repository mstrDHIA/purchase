import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
// import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:provider/provider.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SignUpPage();
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _passwordError;
  String? _confirmPasswordError;

  String _passwordStrength = '';
  Color _strengthColor = Colors.transparent;

  bool _isPasswordStrong(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
        _strengthColor = Colors.transparent;
      } else if (password.length < 6) {
        _passwordStrength = 'Weak';
        _strengthColor = Colors.red;
      } else if (password.length < 10) {
        _passwordStrength = 'Medium';
        _strengthColor = Colors.orange;
      } else {
        _passwordStrength = 'Strong';
        _strengthColor = Colors.green;
      }
    });
  }

  void _validateForm() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _passwordError = _isPasswordStrong(password)
          ? null
          : 'Password must be at least 8 characters,\ninclude upper, lower, and a number.';

      _confirmPasswordError =
          password != confirmPassword ? 'Passwords do not match' : null;
    });

    if (_passwordError == null &&
        _confirmPasswordError == null &&
        _agreeToTerms) {
      // You can add your signup logic here
    } else if (!_agreeToTerms) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
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
            flex: 1,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          'CREATE YOUR ACCOUNT TO START',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      const Text(
                        'Email',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'abc123g@gmail.com',
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
                        obscureText: !_isPasswordVisible,
                        // onChanged: _checkPasswordStrength,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          errorText: _passwordError,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_passwordStrength.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _passwordStrength == 'Weak'
                                  ? 0.33
                                  : _passwordStrength == 'Medium'
                                      ? 0.66
                                      : 1.0,
                              backgroundColor: Colors.grey.shade300,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_strengthColor),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Password strength: $_passwordStrength',
                              style: TextStyle(
                                color: _strengthColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                          errorText: _confirmPasswordError,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value!;
                              });
                            },
                            activeColor: Colors.indigo.shade700,
                          ),
                          const Flexible(
                            child: Text(
                              'I agree to the Terms and services',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Consumer<UserController>(
                        builder: (context, userController, child) {
                          if(userController.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          else{
                            return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // _validateForm();
                                // if (_passwordError == null &&
                                //     _confirmPasswordError == null &&
                                //     _agreeToTerms) {
                                userController.register(
                                   _emailController.text,
                                   _passwordController.text,
                                   context,
                                  //  _formKey
                                );
                              // }
                                // _validateForm();
                                // Only navigate if the form is valid
                                // if (_passwordError == null &&
                                //     _confirmPasswordError == null &&
                                //     _agreeToTerms) {
                                //   // Appel API d'inscription ici
                                //   // print()
                                //   UserNetwork()
                                //       .register(
                                //         password: _passwordController.text,
                                //         username: _emailController.text,
                                //       )
                                //       .then((result) async {
                                //         print('Résultat inscription: $result');
                                //         int? userId;
                                //         try {
                                //           if (result is Map) {
                                //             print('Réponse Map: $result');
                                //             final map = result as Map<String, dynamic>;
                                //             if (map.containsKey('id')) {
                                //               userId = int.tryParse(map['id'].toString());
                                //             } else {
                                //               print('Clé "id" non trouvée dans la Map. Clés disponibles: \\${map.keys}');
                                //             }
                                //           } else {
                                //             print('Réponse String: $result');
                                //             final map = jsonDecode(result);
                                //             if (map is Map && map.containsKey('id')) {
                                //               userId = int.tryParse(map['id'].toString());
                                //             } else {
                                //               print('Clé "id" non trouvée dans la String. Clés disponibles: \\${map.keys}');
                                //             }
                                //           }
                                //         } catch (e) {
                                //           print('Erreur parsing ID: $e');
                                //         }
                                //         if (userId == null) {
                                //           ScaffoldMessenger.of(context).showSnackBar(
                                //             const SnackBar(content: Text("Erreur lors de la création de l'utilisateur. Impossible de récupérer l'ID. Regarde la console pour le debug.")),
                                //           );
                                //           return;
                                //         }
                                //         ScaffoldMessenger.of(context).showSnackBar(
                                //           const SnackBar(content: Text('Inscription réussie.')),
                                //         );
                                //         Navigator.of(context).push(
                                //           MaterialPageRoute(
                                //             builder: (context) => AddUserPage(email: _emailController.text, userId: userId),
                                //           ),
                                //         );
                                //       }).catchError((error) {
                                //         print(error);
                                //         ScaffoldMessenger.of(context).showSnackBar(
                                //           SnackBar(content: Text('Registration failed: $error')),
                                //         );
                                //       });
                                // }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A5ACD),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                          );
                          }
                        }
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInPage()),
                            );
                          },
                          child: const Text(
                            'Already have an account? Sign In',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6A5ACD),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
