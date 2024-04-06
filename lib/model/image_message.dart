import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageMessage
{
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String url;
  final String timestamp;
  final Timestamp time;

  final bool isSeen;
  final String message;

  ImageMessage({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.timestamp,
    required this.url,
    required this.isSeen, required this.message, required this.time,
  });

  Map<String, dynamic> toMap()
  {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'image': url,
      'timestamp': timestamp,
      'isSeen' : isSeen,
      'message' : message,
      'time': time,
    };
  }
}