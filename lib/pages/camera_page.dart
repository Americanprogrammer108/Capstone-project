import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../services/chat/image_chat_service.dart';
import 'chat_page.dart';
import 'homepage.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String receiverUserEmail, receiverUserID, receiverUserName, receiverUserStatus;

  const CameraPage({this.cameras, Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverUserName,
    required this.receiverUserStatus,
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  XFile? pictureFile, videopath;
  bool isTaken = false;
  final ImageChatService _imageChatService = ImageChatService();
  String imageurl = '';
  String videourl = '';
  int currentPageIndex = 0;


  int _selectedCameraIndex = 0;
  bool _isFrontCamera = false;
  bool _isFlashOn = false;

  bool iscamerafront = false;

  //for focus
  Offset? _focusPoint;

  //for zoom
  double _currentZoom = 1.0;
  File? _capturedImage;

  //for making sound
  // AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  //pick up at 4:02 at  https://www.youtube.com/watch?v=VUPzgiSIATQ&list=PL2OW6kiTqhAx64x7ObKg2abY3PZv7fKP2&index=2

  // = await availableCameras();
  // var frontCamera = cameras[0];
  // var backCamera = cameras[1];
  //
  // final CameraController frontCameraController = CameraController(
  //   frontCamera,
  //   ResolutionPreset.medium,
  //   enableAudio: enableAudio,
  //   imageFormatGroup: ImageFormatGroup.jpeg,
  // );
  //
  // final CameraController backCameraController = CameraController(
  //   backCamera,
  //   ResolutionPreset.medium,
  //   enableAudio: enableAudio,
  //   imageFormatGroup: ImageFormatGroup.jpeg,
  // );

  void sendImageMessage(String url) async
  {
    print(widget.receiverUserID);
    print(url);
    await _imageChatService.sendImageMessage(widget.receiverUserID, url);
  }



  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.cameras![0],
      ResolutionPreset.max,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isRecording = false;
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                height: 555,
                width: 650,
                child: isTaken == false?
                CameraPreview(controller)
                    :
                Image.file(
                  File(pictureFile!.path),
                  height: 100,
                ),
              ),
            ),
          ),

        Row(
            children: [
              isTaken == false?
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
                        ),
                      );
                    },
                    icon: Icon(Icons.arrow_back)
                )
              :
                ElevatedButton(
                    onPressed: () async {
                      //retake if not satisfied
                      await availableCameras().then(
                            (value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraPage(cameras: value, receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
                          ),
                        ),
                      );
                    },
                    child: Text("Retake")
                ),
              isTaken == false?
              Text("                             ")
              :
              Text("             "),

              isTaken == false?
                ElevatedButton(
                  onPressed: () async {
                    print("Taking picture...");
                    pictureFile = await controller.takePicture();
                    setState(() {});
                    print("Image: ");
                    print(pictureFile?.path);
                    isTaken = true;
                    imageurl = pictureFile!.path.toString();
                  },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            width: 4,
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          )
                      ),
                    ),
                )
              :
              ElevatedButton(
                onPressed: () async {
                  //send if satisfied
                  // print(imageurl);
                  // String fileName = Uuid().v1();
                  // var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
                  // var uploadTask = await ref.putFile(_capturedImage!);
                  // imageurl = await uploadTask.ref.getDownloadURL();
                  // print(imageurl);

                  sendImageMessage(imageurl);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
                    ),
                  );
                },
                child: Text("Send picture"),
              ),
              isTaken == false?
                  Text("                             ")
              :
                  Text(" "),
              isTaken == false?
                IconButton(
                    onPressed: () async {
                      // int cameraPos = iscamerafront? 0:1;
                      // controller = CameraController(
                      //   cameras[cameraPos], ResolutionPreset.high);
                      // _cameraValue = _cameraController.initialize();
                    },
                    icon: Icon(Icons.switch_camera)
                )
              :
                Text(""),
            ],
          )
        ],
      ),
      //   Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Center(
      //           child: SizedBox(
      //             height: 555,
      //             width: 650,
      //             child: isTaken == false?
      //             CameraPreview(controller)
      //                 :
      //             Image.file(
      //               File(pictureFile!.path),
      //               height: 100,
      //             ),
      //           ),
      //         ),
      //       ),
      //       Row(
      //         children: [
      //           isTaken == false?
      //             IconButton(
      //                 onPressed: () {
      //                   Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                       builder: (context) => ChatPage(receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
      //                     ),
      //                   );
      //                 },
      //                 icon: Icon(Icons.arrow_back)
      //             )
      //           :
      //             ElevatedButton(
      //                 onPressed: () async {
      //                   //retake if not satisfied
      //                   await availableCameras().then(
      //                         (value) => Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                         builder: (context) => CameraPage(cameras: value, receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
      //                       ),
      //                     ),
      //                   );
      //                 },
      //                 child: Text("Retake")
      //             ),
      //           isTaken == false?
      //           Text("                             ")
      //           :
      //           Text("             "),
      //
      //           isTaken == false?
      //             ElevatedButton(
      //               onPressed: () async {
      //                 print("Taking picture...");
      //                 pictureFile = await controller.takePicture();
      //                 setState(() {});
      //                 print("Image: ");
      //                 print(pictureFile?.path);
      //                 isTaken = true;
      //                 imageurl = pictureFile!.path.toString();
      //               },
      //                 child: Container(
      //                   width: 50,
      //                   height: 50,
      //                   decoration: BoxDecoration(
      //                       color: Colors.white,
      //                       borderRadius: BorderRadius.circular(50),
      //                       border: Border.all(
      //                         width: 4,
      //                         color: Colors.grey,
      //                         style: BorderStyle.solid,
      //                       )
      //                   ),
      //                 ),
      //             )
      //           :
      //           ElevatedButton(
      //             onPressed: () async {
      //               //send if satisfied
      //               print(imageurl);
      //               String fileName = Uuid().v1();
      //               var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
      //               var uploadTask = await ref.putFile(_capturedImage!);
      //               imageurl = await uploadTask.ref.getDownloadURL();
      //               print(imageurl);
      //               // sendImageMessage(imageurl);
      //               // Navigator.push(
      //               //   context,
      //               //   MaterialPageRoute(
      //               //     builder: (context) => ChatPage(receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
      //               //   ),
      //               // );
      //             },
      //             child: Text("Send picture"),
      //           ),
      //           isTaken == false?
      //               Text("                             ")
      //           :
      //               Text(" "),
      //           isTaken == false?
      //             IconButton(
      //                 onPressed: () async {
      //                   // int cameraPos = iscamerafront? 0:1;
      //                   // controller = CameraController(
      //                   //   cameras[cameraPos], ResolutionPreset.high);
      //                   // _cameraValue = _cameraController.initialize();
      //                 },
      //                 icon: Icon(Icons.switch_camera)
      //             )
      //           :
      //             Text(""),
      //         ],
      //       )
      //     ],
      //   ),
      //
      //   //video section
      //   Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Center(
      //           child: SizedBox(
      //             height: 555,
      //             width: 650,
      //             child: isTaken == false?
      //             CameraPreview(controller)
      //                 :
      //             Image.file(
      //               File(pictureFile!.path),
      //               height: 100,
      //             ),
      //           ),
      //         ),
      //       ),
      //       Row(
      //         children: [
      //           IconButton(
      //               onPressed: () {
      //                 Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => ChatPage(receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
      //                   ),
      //                 );
      //               },
      //               icon: Icon(Icons.arrow_back)
      //           ),
      //           Text("                             "),
      //           ElevatedButton(
      //             onPressed: () async {
      //
      //               // pictureFile = await controller.takePicture();
      //               // setState(() {});
      //               // print("Image: ");
      //               // print(pictureFile?.path);
      //               // isTaken = true;
      //
      //               if(isRecording == false)
      //               {
      //                 print("Recording video...");
      //
      //                 isRecording = true;
      //                 await controller.startVideoRecording();
      //               }
      //               else
      //               {
      //                 print("Video recording stopped");
      //                 isRecording = false;
      //                 videopath = await controller.stopVideoRecording();
      //                 videourl = videopath!.path.toString();
      //
      //                 //preview the video
      //               }
      //             },
      //             child: Container(
      //               width: 50,
      //               height: 50,
      //               decoration: BoxDecoration(
      //                   color: Colors.red,
      //                   borderRadius: BorderRadius.circular(50),
      //                   border: Border.all(
      //                     width: 4,
      //                     color: Colors.grey,
      //                     style: BorderStyle.solid,
      //                   )
      //               ),
      //             ),
      //           ),
      //           Text("                             "),
      //           IconButton(
      //             onPressed: () {
      //
      //             },
      //             icon: Icon(Icons.switch_camera)
      //           ),
      //         ],
      //       )
      //
      //     ],
      //   ),
      //
      //   // Column(
      //   //   children: [
      //   //     Padding(
      //   //       padding: const EdgeInsets.all(8.0),
      //   //       child: Center(
      //   //         child: SizedBox(
      //   //           height: 555,
      //   //           width: 650,
      //   //           child: isTaken == false?
      //   //           CameraPreview(controller)
      //   //               :
      //   //           Image.file(
      //   //             File(pictureFile!.path),
      //   //             height: 100,
      //   //           ),
      //   //         ),
      //   //       ),
      //   //     ),
      //   //   ],
      //   // ),
      // // Column(
      // // children: [
      //   // Padding(
      //   //   padding: const EdgeInsets.all(8.0),
      //   //   child: Center(
      //   //     child: SizedBox(
      //   //       height: 555,
      //   //       width: 650,
      //   //       child: isTaken == false?
      //   //         CameraPreview(controller)
      //   //           :
      //   //         Image.file(
      //   //         File(pictureFile!.path),
      //   //         height: 100,
      //   //         ),
      //   //     ),
      //   //   ),
      //   // ),
      //
      //   // Container(
      //   //   width: 50,
      //   //   height: 50,
      //   //   decoration: BoxDecoration(
      //   //     color: currentPageIndex == 1?
      //   //     Colors.white
      //   //       :
      //   //     Colors.red,
      //   //     borderRadius: BorderRadius.circular(50),
      //   //     border: Border.all(
      //   //       width: 4,
      //   //       color: Colors.white,
      //   //       style: BorderStyle.solid,
      //   //     )
      //   //   ),
      //   // ),
      //   // Card(
      //   //   child: Row(
      //   //     children: [
      //   //       // IconButton(
      //   //       //   onPressed: () async {
      //   //       //     Navigator.push(
      //   //       //       context,
      //   //       //       MaterialPageRoute(
      //   //       //         builder: (context) => ChatPage(receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
      //   //       //       ),
      //   //       //     );
      //   //       //   },
      //   //       //   icon: Icon(Icons.arrow_left),
      //   //       // ),
      //   //
      //   //       isTaken == false?
      //   //       Row(
      //   //         children: [
      //   //           IconButton(
      //   //             onPressed: () async {
      //   //               print("Taking picture...");
      //   //               pictureFile = await controller.takePicture();
      //   //               setState(() {});
      //   //               print("Image: ");
      //   //               print(pictureFile?.path);
      //   //               isTaken = true;
      //   //               imageurl = pictureFile!.path.toString();
      //   //             },
      //   //             icon: Icon(Icons.camera),
      //   //           ),
      //   //
      //   //           IconButton(
      //   //             onPressed: () async {
      //   //               print("Recording video...");
      //   //             },
      //   //             icon: Icon(Icons.video_call),
      //   //           ),
      //   //
      //   //           IconButton(
      //   //             onPressed: () async {
      //   //             //   switch from rear to front camera
      //   //               print("Switching camera...");
      //   //               // CameraPreview(backCameraController);
      //   //             },
      //   //             icon: Icon(Icons.cameraswitch),
      //   //           )
      //   //         ],
      //   //       )
      //   //       :
      //   //       Row(
      //   //         children: [
      //   //           ElevatedButton(
      //   //             onPressed: () async {
      //   //               sendImageMessage(imageurl);
      //   //               Navigator.push(
      //   //                 context,
      //   //                 MaterialPageRoute(
      //   //                   builder: (context) => ChatPage(receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
      //   //                 ),
      //   //               );
      //   //             },
      //   //             child: Text('Send picture'),
      //   //           ),
      //   //           ElevatedButton(
      //   //             onPressed: () async {
      //   //               isTaken = false;
      //   //               print(isTaken);
      //   //               await availableCameras().then(
      //   //                     (value) => Navigator.push(
      //   //                   context,
      //   //                   MaterialPageRoute(
      //   //                     builder: (context) => CameraPage(cameras: value, receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
      //   //                   ),
      //   //                 ),
      //   //               );
      //   //             },
      //   //             child: Text('Retake'),
      //   //           ),
      //   //         ],
      //   //       ),
      //   //     ],
      //   //   ),
      //   // ),
      //     //Android/iOS
      //     // Image.file(File(pictureFile!.path)))
      //   // ],
      // // ),
    );
  }
}
