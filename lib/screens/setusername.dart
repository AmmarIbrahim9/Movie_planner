import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'UserprofilePage.dart';

class SetUsernamePage extends StatefulWidget {
  const SetUsernamePage({Key? key}) : super(key: key);

  @override
  _SetUsernamePageState createState() => _SetUsernamePageState();
}

class _SetUsernamePageState extends State<SetUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _setUsername() async {
    final User? user = _auth.currentUser;
    if (user != null && _usernameController.text.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).set({
        'username': _usernameController.text,
        'isActive': true,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Set Username",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Set back button color
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // Transparent white background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black), // Black border around container
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 60,
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7), // Transparent white background for input field
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black), // Black border around input field
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'Enter Username',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _setUsername,
                      child: const Text("Set Username"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
