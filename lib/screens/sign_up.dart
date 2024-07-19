import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/authentication_services.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _signUp() async {
    // Reset error messages
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _error = null;
    });

    // Validate email
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    } else if (!isValidEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Invalid email format';
      });
      return;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Confirm Password cannot be empty';
      });
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      // Attempt to sign up with Firebase
      await authService.signUp(_emailController.text, _passwordController.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      // Handle specific errors thrown by Firebase authentication
      if (e is FirebaseAuthException) {
        setState(() {
          if (e.code == 'weak-password') {
            _error = 'The password provided is too weak.';
          } else if (e.code == 'email-already-in-use') {
            _error = 'The account already exists for that email.';
          } else if (e.code == 'invalid-email') {
            _error = 'The email address is invalid.';
          } else {
            _error = 'Error occurred, please try again later.';
          }
        });
      } else {
        // Handle other exceptions that may occur
        setState(() {
          _error = 'Error occurred, please try again later.';
        });
      }
    }
  }

  bool isValidEmail(String email) {
    // Simple email validation regex
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.indigo.shade900, Colors.blueGrey.shade900],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 8,
                      color: Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 40),
                            Center(
                              child: Icon(
                                Icons.movie,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _emailController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(Icons.email, color: Colors.white),
                                errorText: _emailError,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(Icons.lock, color: Colors.white),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                errorText: _passwordError,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              obscureText: _obscurePassword,
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _confirmPasswordController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(Icons.lock, color: Colors.white),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleConfirmPasswordVisibility,
                                ),
                                errorText: _confirmPasswordError,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              obscureText: _obscureConfirmPassword,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 16, color: Colors.indigo.shade900),
                              ),
                            ),
                            if (_error != null) ...[
                              SizedBox(height: 20),
                              Text(
                                _error!,
                                style: TextStyle(color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
