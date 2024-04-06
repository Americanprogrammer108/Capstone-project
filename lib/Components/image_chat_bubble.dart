import 'package:flutter/material.dart';

class ImageBubble extends StatelessWidget
{
  final String url;
  const ImageBubble({
    super.key,
    required this.url
  });

  @override
  Widget build(BuildContext context)
  {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      width: 200,
      height: 200
    );
  }
}