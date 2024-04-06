import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget
{
  final String message;
  final Color usercolor;
  final String url;

  const ChatBubble({
    super.key,
    required this.message,
    required this.usercolor,
    required this.url,
  });

  @override
  Widget build(BuildContext context)
  {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: usercolor,
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}