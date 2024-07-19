import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie.dart';
import 'Trailer_screen.dart'; // Import TrailerScreen if it's defined in another file

class ChatScreen extends StatefulWidget {
  final String receiverId;

  ChatScreen({required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  late User _user;
  String _senderName = '';
  String _receiverName = '';
  ScrollController _scrollController = ScrollController(); // Added ScrollController

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _fetchNames();
  }

  Future<void> _fetchNames() async {
    try {
      // Fetch sender's name
      DocumentSnapshot senderSnapshot = await _firestore.collection('users').doc(_user.uid).get();
      _senderName = senderSnapshot['username'];

      // Fetch receiver's name
      DocumentSnapshot receiverSnapshot = await _firestore.collection('users').doc(widget.receiverId).get();
      _receiverName = receiverSnapshot['username'];

      setState(() {}); // Refresh the UI after fetching names
    } catch (e) {
      print('Error fetching names: $e');
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      try {
        // Check if message includes movie details
        bool isMovieMessage = _controller.text.startsWith('Check out this movie:');
        if (isMovieMessage) {
          // Extract movie details
          String content = _controller.text;
          String title = content.substring(content.indexOf(':') + 1, content.indexOf('\nOverview:'));
          String overview = content.substring(content.indexOf('Overview:') + 9, content.indexOf('\nTrailer:'));
          String trailerLink = content.substring(content.indexOf('Trailer:') + 8);

          // Send message with movie details
          await _firestore.collection('messages').add({
            'senderId': _user.uid,
            'senderName': _senderName,
            'receiverId': widget.receiverId,
            'receiverName': _receiverName,
            'content': content,
            'timestamp': FieldValue.serverTimestamp(),
            'participants': [_user.uid, widget.receiverId],
            'movie': {
              'title': title.trim(),
              'overview': overview.trim(),
              'trailerLink': trailerLink.trim(),
            },
          });
        } else {
          // Send regular message
          await _firestore.collection('messages').add({
            'senderId': _user.uid,
            'senderName': _senderName,
            'receiverId': widget.receiverId,
            'receiverName': _receiverName,
            'content': _controller.text,
            'timestamp': FieldValue.serverTimestamp(),
            'participants': [_user.uid, widget.receiverId],
          });
        }

        _controller.clear();
        _scrollToBottom(); // Scroll to bottom after sending message
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message'),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _extractVideoId(String youtubeUrl) {
    return YoutubePlayer.convertUrlToId(youtubeUrl) ?? '';
  }

  bool _isMessageOlderThanOneDay(Timestamp? timestamp) {
    if (timestamp == null) return false;
    DateTime messageTime = timestamp.toDate();
    DateTime now = DateTime.now();
    return now.difference(messageTime).inDays > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.purple],
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('participants', arrayContains: _user.uid)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet', style: TextStyle(color: Colors.grey)));
                }
                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final messageData = message.data() as Map<String, dynamic>;
                  final bool isMovieMessage = messageData.containsKey('movie');
                  final bool isOldMessage = _isMessageOlderThanOneDay(messageData['timestamp']);
                  if ((messageData['senderId'] == _user.uid && messageData['receiverId'] == widget.receiverId) ||
                      (messageData['receiverId'] == _user.uid && messageData['senderId'] == widget.receiverId)) {
                    final messageWidget = _buildMessageWidget(messageData, isMovieMessage, isOldMessage);
                    messageWidgets.add(messageWidget);
                  }
                }
                WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom()); // Ensure scroll to bottom on update
                return ListView(
                  controller: _scrollController, // Assign ScrollController
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(Map<String, dynamic> messageData, bool isMovieMessage, bool isOldMessage) {
    final isMe = messageData['senderId'] == _user.uid;
    final formattedTime = messageData['timestamp'] != null ? DateFormat('h:mm a').format(messageData['timestamp'].toDate()) : '';
    final messageContent = isMovieMessage ? 'Check out this movie:' : messageData['content'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMovieMessage ? 'Check out this movie:' : messageData['content'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, fontFamily: 'Roboto'), // Example of updated font
                ),
                SizedBox(height: 8.0),
                if (isMovieMessage)
                  _buildMovieDetails(messageData)
                else
                  SizedBox.shrink(),
                SizedBox(height: 8.0),
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                ),
                if (isOldMessage)
                  Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(messageData['timestamp'].toDate()),
                      style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieDetails(Map<String, dynamic> messageData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${messageData['movie']['title']}',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        messageData['movie']['posterPath'] != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/placeholder_image.png', // Placeholder image asset
            image: 'https://image.tmdb.org/t/p/w500${messageData['movie']['posterPath']}',
            height: 150,
            width: 100,
            fit: BoxFit.cover,
          ),
        )
            : SizedBox.shrink(),
        SizedBox(height: 8.0),
        _buildOverviewTile(messageData['movie']['overview']),
        SizedBox(height: 12.0),
        if (messageData['movie']['trailerLink'] != null)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrailerScreen(videoId: _extractVideoId(messageData['movie']['trailerLink'])),
                ),
              );
            },
            icon: Icon(Icons.play_arrow),
            label: Text('Watch Trailer'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOverviewTile(String overview) {
    return ExpansionTile(
      title: Text(
        'Overview',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            overview,
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      ],
    );
  }
}
