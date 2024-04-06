import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

class videoCall extends StatefulWidget {
  const videoCall({super.key});

  @override
  State<videoCall> createState() => _videoCallState();
}

class _videoCallState extends State<videoCall> {
  final AgoraClient client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(appId: 'appId', channelName: "test"),
      enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  @override
  void initState()
  {
    super.initState();
    initAgora();
  }

  void initAgora() async
  {
    await client.initialize();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agora VideoUIKit'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: client,
                layoutType: Layout.floating,
                enableHostControls: true, // Add this to enable host controls
              ),
              AgoraVideoButtons(
                client: client,
                addScreenSharing: false, // Add this to enable screen sharing
              ),
            ],
          ),
        ),
      ),
    );
  }
}
