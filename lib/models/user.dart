// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class User {
//   final String userId;
//   List<int> watchLaterMovies;
//
//   User({
//     required this.userId,
//     required this.watchLaterMovies,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'watchLaterMovies': watchLaterMovies,
//     };
//   }
//
//   static User fromMap(Map<String, dynamic> map) {
//     return User(
//       userId: map['userId'],
//       watchLaterMovies: List<int>.from(map['watchLaterMovies']),
//     );
//   }
// }
//
// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   // Save or update user document
//   Future<void> saveUser(User user) async {
//     await _db.collection('users').doc(user.userId).set(user.toMap());
//   }
//
//   // Get current user from Firestore
//   Future<User?> getCurrentUser(String userId) async {
//     try {
//       DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
//       if (doc.exists) {
//         return User.fromMap(doc.data() as Map<String, dynamic>);
//       }
//       return null;
//     } catch (e) {
//       print('Error getting user: $e');
//       return null;
//     }
//   }
//
//   // Update watch later movies for user
//   Future<void> updateWatchLater(String userId, List<int> movieIds) async {
//     await _db.collection('users').doc(userId).update({
//       'watchLaterMovies': movieIds,
//     });
//   }
// }
