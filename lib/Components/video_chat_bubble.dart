import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBubble extends StatelessWidget
{
  final String url;
  final VideoPlayerController controller;
  const VideoBubble({
    super.key,
    required this.url,
    required this.controller
  });

  @override
  Widget build(BuildContext context)
  {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      width: 200,
      height: 200,
      child: VideoPlayer(controller)
    );
  }
}