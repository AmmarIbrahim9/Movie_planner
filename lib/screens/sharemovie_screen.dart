import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShareMovieScreen extends StatefulWidget {
  final Movie movie;

  ShareMovieScreen({required this.movie});

  @override
  _ShareMovieScreenState createState() => _ShareMovieScreenState();
}

class _ShareMovieScreenState extends State<ShareMovieScreen> {
  Set<String> selectedUsers = Set();
  bool isSending = false;

  Future<void> _shareMovieWithUsers(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Fetch trailer information
      final response = await http.get(
        Uri.parse(
          'https://api.themoviedb.org/3/movie/${widget.movie.id}/videos?api_key=c351c1de7750be81fda835f9d938c1f9',
        ),
      );

      String trailerLink = '';
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['results'].isNotEmpty) {
          trailerLink = 'https://www.youtube.com/watch?v=${jsonData['results'][0]['key']}';
        }
      }

      // Prepare message content
      String messageContent = 'Check out this movie: ${widget.movie.title}\nOverview: ${widget.movie.overview}\nTrailer: $trailerLink';

      // Prepare message data
      Map<String, dynamic> messageData = {
        'senderId': currentUser.uid,
        'content': messageContent,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [currentUser.uid],
        'movie': {
          'title': widget.movie.title,
          'overview': widget.movie.overview,
          'posterPath': widget.movie.posterPath,
          'trailerLink': trailerLink,
        },
      };

      // Add selected users to participants list and send messages
      selectedUsers.forEach((userId) {
        messageData['participants'].add(userId);
        messageData['receiverId'] = userId;
        FirebaseFirestore.instance.collection('messages').add(messageData);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Movie shared with ${selectedUsers.length} ${selectedUsers.length == 1 ? 'user' : 'users'}'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to previous screen
      Navigator.pop(context);
    }
  }

  String _extractVideoId(String youtubeUrl) {
    return YoutubePlayer.convertUrlToId(youtubeUrl) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Share ${widget.movie.title}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;
                    final userName = userData['username'] ?? 'Unknown';
                    final userId = users[index].id;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: selectedUsers.contains(userId) ? 1.0 : 0.6,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            title: Text(userName),
                            value: selectedUsers.contains(userId),
                            onChanged: isSending
                                ? null
                                : (bool? checked) {
                              setState(() {
                                if (checked!) {
                                  selectedUsers.add(userId);
                                } else {
                                  selectedUsers.remove(userId);
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: selectedUsers.isEmpty || isSending ? null : () {
                    setState(() {
                      isSending = true;
                    });
                    _shareMovieWithUsers(context).then((_) {
                      setState(() {
                        isSending = false;
                      });
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: isSending
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Share with ${selectedUsers.length} ${selectedUsers.length == 1 ? 'user' : 'users'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
