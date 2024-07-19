import 'package:flutter/material.dart';
import 'package:movie_planner/screens/sign_up.dart';
import 'package:provider/provider.dart';
import '../services/authentication_services.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _signInError;
  bool _showPassword = false;

  void _toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _signInError = null;
    });
  }

  Future<void> _signIn() async {
    _clearErrors();
    final authService = Provider.of<AuthService>(context, listen: false);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    }

    try {
      await authService.signIn(email, password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      setState(() {
        _signInError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
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
            child: Container(
              height: MediaQuery.of(context).size.height,
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
                            SizedBox(height: 100), // Adjust the height as needed
                            Center(
                              child: Icon(
                                Icons.movie,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildEmailTextField(),
                            SizedBox(height: 20),
                            _buildPasswordTextField(),
                            SizedBox(height: 20),
                            _buildSignInButton(),
                            SizedBox(height: 10),
                            if (_signInError != null) ...[
                              SizedBox(height: 10),
                              _buildErrorText(),
                            ],
                            SizedBox(height: 20),
                            _buildCreateAccountButton(),
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

  Widget _buildEmailTextField() {
    return TextFormField(
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
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(Icons.lock, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: _toggleShowPassword,
          color: Colors.white,
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
      obscureText: !_showPassword,
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _signIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        'Sign In',
        style: TextStyle(fontSize: 16, color: Colors.indigo.shade900),
      ),
    );
  }

  Widget _buildErrorText() {
    return Text(
      _signInError!,
      style: TextStyle(color: Colors.red, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCreateAccountButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
      },
      child: Text(
        'Create an account',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
