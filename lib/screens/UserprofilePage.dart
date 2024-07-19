import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_planner/screens/setusername.dart';
import 'chatting.dart'; // Make sure to create this file for the ChatScreen

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  String? username;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    user = _auth.currentUser;
    if (user != null) {
      firestore.collection('users').doc(user!.uid).get().then((doc) {
        if (doc.exists) {
          setState(() {
            username = doc['username'];
          });
        }
      });
      updateUserStatus(true); // User is active when the app is opened
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (user != null) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
        updateUserStatus(false); // User is inactive when the app is in background
      } else if (state == AppLifecycleState.resumed) {
        updateUserStatus(true); // User is active when the app is in foreground
      }
    }
  }

  void updateUserStatus(bool isActive) async {
    if (user != null) {
      final docRef = firestore.collection('users').doc(user!.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'isActive': isActive,
        });
      } else {
        firestore.collection('users').doc(user!.uid).set({
          'isActive': isActive,
        });
      }
    }
  }

  Widget _buildUserTile(String userName, bool isActive, String userId) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(Icons.person, color: Colors.grey, size: 36),
            radius: 24,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      isActive ? "Active" : "Inactive",
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(receiverId: userId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return SetUsernamePage();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Users",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;
                final userName = userData['username'] ?? 'Unknown';
                final isActive = userData['isActive'] ?? false;
                return _buildUserTile(userName, isActive, users[index].id);
              },
            );
          },
        ),
      );
    }
  }
}
