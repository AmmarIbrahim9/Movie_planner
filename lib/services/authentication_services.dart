import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? _user;

  AuthService() {
    _firebaseAuth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An unknown error occurred";
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An unknown error occurred";
    }
  }
  void _updateUserStatus(bool isActive) async {
    if (user != null) {
      await firestore.collection('users').doc(user!.uid).update({
        'isActive': isActive,
      });
    }
  }

  Future<void> signOut() async {
    _updateUserStatus(false);
    await _firebaseAuth.signOut();
  }
}
