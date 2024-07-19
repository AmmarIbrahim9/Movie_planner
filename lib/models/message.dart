// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Message {
//   final String senderId;
//   final String senderName;
//   final String receiverId;
//   final String receiverName;
//   final String content;
//   final Timestamp timestamp;
//   final List<String> participants;
//   final MessageType type;
//   final String movieId; // Additional field for movie share links
//
//   Message({
//     required this.senderId,
//     required this.senderName,
//     required this.receiverId,
//     required this.receiverName,
//     required this.content,
//     required this.timestamp,
//     required this.participants,
//     required this.type,
//     this.movieId = '', // Initialize movieId as empty string
//   });
//
//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       senderId: json['senderId'] ?? '',
//       senderName: json['senderName'] ?? '',
//       receiverId: json['receiverId'] ?? '',
//       receiverName: json['receiverName'] ?? '',
//       content: json['content'] ?? '',
//       timestamp: json['timestamp'] ?? Timestamp.now(),
//       participants: List<String>.from(json['participants'] ?? []),
//       type: MessageTypeExtension.fromString(json['type'] ?? ''),
//       movieId: json['movieId'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'senderId': senderId,
//       'senderName': senderName,
//       'receiverId': receiverId,
//       'receiverName': receiverName,
//       'content': content,
//       'timestamp': timestamp,
//       'participants': participants,
//       'type': type.toString(),
//       'movieId': movieId,
//     };
//   }
// }
//
// enum MessageType {
//   Text,
//   Link,
// }
//
// extension MessageTypeExtension on MessageType {
//   static MessageType fromString(String type) {
//     switch (type) {
//       case 'text':
//         return MessageType.Text;
//       case 'link':
//         return MessageType.Link;
//       default:
//         return MessageType.Text; // Default to Text message
//     }
//   }
//
//   @override
//   String toString() {
//     switch (this) {
//       case MessageType.Text:
//         return 'text';
//       case MessageType.Link:
//         return 'link';
//       default:
//         return 'text'; // Default to 'text'
//     }
//   }
// }
