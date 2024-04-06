import 'package:cloud_firestore/cloud_firestore.dart';

class Call
{
  final String name;
  final String timestamp;
  final String date;
  final String image;
  final Timestamp time;

  Call({
    required this.name,
    required this.timestamp,
    required this.date,
    required this.image,
    required this.time,
  });

  Map<String, dynamic> toMap()
  {
    return {
      'senderID': name,
      'timestamp': timestamp,
      'image' : image,
      'time': time,
    };
  }
}