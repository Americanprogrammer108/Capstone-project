import 'package:cloud_firestore/cloud_firestore.dart';

class Message
{
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final String timestamp;
  final String image;
  final bool isSeen;
  final Timestamp time;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.timestamp,
    required this.message,
    required this.isSeen,
    required this.image, required this.time,
  });

  Map<String, dynamic> toMap()
  {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'isSeen' : isSeen,
      'image' : image,
      'time': time,
    };
  }
}