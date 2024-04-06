// import 'dart:html';
import 'dart:typed_data';
import 'dart:io' as io;

import 'package:agora_uikit/agora_uikit.dart';
import 'package:camera/camera.dart';
import 'package:capstone_project/Components/my_text_field.dart';
import 'package:capstone_project/pages/video_call.dart';
import 'package:capstone_project/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../Components/chat_bubble.dart';
import '../Components/image_chat_bubble.dart';
import '../services/chat/call_service.dart';
import '../services/chat/image_chat_service.dart';
import '../utils.dart';
import 'camera_page.dart';
import 'homepage.dart';

enum selectanoption {itemOne, itemTwo}

class ChatPage extends StatefulWidget
{
  final String receiverUserEmail, receiverUserID, receiverUserName, receiverUserStatus;
  const ChatPage({super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverUserName,
    required this.receiverUserStatus,
  });
  String getEmail()
  {
    return receiverUserEmail;
  }
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
{
  bool light1 = true;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();
  final ImageChatService _imageChatService = ImageChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Uint8List? _image;
  io.File? imageFile;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _showEmoji = false, _isUploading = false;
  //constant variables
  List<Map<String, dynamic>> membersList = [];

  String getTime()
  {
    String AMorPM = "AM";
    int currenthour = 0;
    if (DateTime.now().hour < 12)
    {
      if(DateTime.now().hour == 0)
      {
        currenthour = 12;
      }
      else if(DateTime.now().hour == 1)
      {
        currenthour = 1;
      }
      else if(DateTime.now().hour == 2)
      {
        currenthour = 2;
      }
      else if(DateTime.now().hour == 3)
      {
        currenthour = 3;
      }
      else if(DateTime.now().hour == 4)
      {
        currenthour = 4;
      }
      else if(DateTime.now().hour == 5)
      {
        currenthour = 5;
      }
      else if(DateTime.now().hour == 6)
      {
        currenthour = 6;
      }
      else if(DateTime.now().hour == 7)
      {
        currenthour = 7;
      }
      else if(DateTime.now().hour == 8)
      {
        currenthour = 8;
      }
      else if(DateTime.now().hour == 9)
      {
        currenthour = 9;
      }
      else if(DateTime.now().hour == 10)
      {
        currenthour = 10;
      }
      else if(DateTime.now().hour == 11)
      {
        currenthour = 11;
      }
      AMorPM = "AM";
    }
    else if (DateTime.now().hour == 12)
    {
      currenthour = 12;
    }
    else
    {
      if(DateTime.now().hour == 13)
      {
        currenthour = 1;
      }
      else if(DateTime.now().hour == 14)
      {
        currenthour = 2;
      }
      else if(DateTime.now().hour == 15)
      {
        currenthour = 3;
      }
      else if(DateTime.now().hour == 16)
      {
        currenthour = 4;
      }
      else if(DateTime.now().hour == 17)
      {
        currenthour = 5;
      }
      else if(DateTime.now().hour == 18)
      {
        currenthour = 6;
      }
      else if(DateTime.now().hour == 19)
      {
        currenthour = 7;
      }
      else if(DateTime.now().hour == 20)
      {
        currenthour = 8;
      }
      else if(DateTime.now().hour == 21)
      {
        currenthour = 9;
      }
      else if(DateTime.now().hour == 22)
      {
        currenthour = 10;
      }
      else if(DateTime.now().hour == 23)
      {
        currenthour = 11;
      }
      AMorPM = "PM";
    }

    print(DateTime.now().month.toString() + "-" + DateTime.now().day.toString() + "-" + DateTime.now().year.toString() +  " " + currenthour.toString() + ":" + DateTime.now().minute.toString() + AMorPM);
    return DateTime.now().month.toString() + "-" + DateTime.now().day.toString() + "-" + DateTime.now().year.toString() +  " " + currenthour.toString() + ":" + DateTime.now().minute.toString() + AMorPM;
  }

  void sendMessage() async
  {
    if (_messageController.text.isNotEmpty)
    {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text, getTime());
      _messageController.clear();
    }
    // sendNotification();
  }
  // 5:22 is where the sendMessage function is modified

  void makephoneCall(receiverID, String fullname, String image, String time, String datenow) async
  {
    await _callService.makeCall(receiverID, fullname, image, time, datenow);
  }

  void receivephoneCall(receiverID, String fullname, String image, String time, String datenow) async
  {
    await _callService.receiveCall(receiverID, fullname, image, time, datenow);
  }

  void sendImageMessage(String url) async
  {
    print(widget.receiverUserID);
    print(url);
    await _imageChatService.sendImageMessage(widget.receiverUserID, url);
    _messageController.clear();
  }

  Future getImage() async
  {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((XFile? xFile) {
      if (xFile != null)
      {
        imageFile = io.File(xFile.path);
        print("Image: " + imageFile.toString());
        uploadImage();
      }
    });
  }
// pick up at
  Future uploadImage() async
  {
    String fileName = Uuid().v1();
    int status = 1;
    var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!);
    if (status == 1)
    {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      print("Image URL: " + imageUrl.toString());
      sendImageMessage(imageUrl.toString());
      return NetworkImage(imageUrl.toString());
    }
  }

  Future<void> outgoing(String uid, String phone,String name, String image, String type, DateTime datetime, String time)
  async {
    Map<String, dynamic> outgoingCall =
    {
      'Phone': phone,
      'Name': name,
      'image': image,
      'In or Out' : 'In',
      'Time': DateTime.now(),
      'Time called' : getTime().toString(),
    };
    print(outgoingCall);
    // await _firestore
    //     .collection('users')
    //     .doc(uid)
    //     .collection('Missed calls')
    //     .add(outgoingCall);
    _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid)
        .collection("Missed calls").doc(_firebaseAuth.currentUser!.uid).set(outgoingCall);
  }
  void incoming(String phone,String name, String image, String type, DateTime datetime, String time)
  async {
    Map<String, dynamic> incomingCall =
    {
      'Phone': phone,
      'Name': name,
      'image': image,
      'In or Out' : 'Out',
      'Time': DateTime.now(),
      'Time called' : getTime().toString(),
    };
    print(incomingCall);
    // await _firestore
    //     .collection('users')
    //     .doc(_firebaseAuth.currentUser!.uid)
    //     .collection('Missed calls')
    //     .add(incomingCall);
    _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid)
    .collection("Missed calls").doc(_firebaseAuth.currentUser!.uid).set(incomingCall);
  }

  @override
  Widget build(BuildContext context)
  {
    Color? backgroundcolor = light1 ? Colors.grey[900] : Colors.white;
    Color textColor = light1 ? Colors.white : Colors.black;
    Color? iconcolor = light1 ? Colors.white70 : Colors.grey[800];
    Color? appbarcolor = light1 ? Colors.grey[800] : Colors.grey[200];
    return Scaffold(
        backgroundColor: Colors.grey,
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users')
                .doc(widget.receiverUserID)
                .snapshots(),
            builder:(context, snapshot)
            {
              if(!snapshot.hasData)
              {
                return const CircularProgressIndicator();
              }
              var output = snapshot.data!.data();
              var name = output!['Fullname'];
              var image = output!['profileImage'];
              var darkmode = output!['darkmode'];

              return Scaffold(
                backgroundColor: darkmode == true? Colors.grey[800] : Colors.grey[200],
                appBar: AppBar(
                  leading: IconButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.home),
                  ),
                  title: new Row
                    (
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:
                    [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: image != "" ?
                        NetworkImage(image) :
                        NetworkImage("https://cdn-icons-png.freepik.com/512/12225/12225935.png"),
                      ),
                      Text("   "),
                      Text(name, style: TextStyle(fontSize: 15)),

                    ],
                  ),
                  actions:
                  [
                    IconButton(
                      onPressed: () async {
                        // await FlutterPhoneDirectCaller.callNumber(output!['Phone']);
                        // print(_firebaseAuth.currentUser!.uid);
                        await _firestore
                            .collection('users')
                            .doc(_firebaseAuth.currentUser!.uid)
                            .get()
                            .then((map) {
                              print(map['Fullname']);
                              print(map['profileImage']);
                              print(map['Phone']);
                              print(DateTime.now());
                              String AMorPM = "AM";
                              int currenthour = 0;
                              if (DateTime.now().hour < 12)
                              {
                                if(DateTime.now().hour == 0)
                                {
                                  currenthour = 12;
                                }
                                AMorPM = "AM";
                              }
                              else
                              {
                                if(DateTime.now().hour == 13)
                                {
                                  currenthour = 1;
                                }
                                else if(DateTime.now().hour == 14)
                                {
                                  currenthour = 2;
                                }
                                else if(DateTime.now().hour == 15)
                                {
                                  currenthour = 3;
                                }
                                else if(DateTime.now().hour == 16)
                                {
                                  currenthour = 4;
                                }
                                else if(DateTime.now().hour == 17)
                                {
                                  currenthour = 5;
                                }
                                else if(DateTime.now().hour == 18)
                                {
                                  currenthour = 6;
                                }
                                else if(DateTime.now().hour == 19)
                                {
                                  currenthour = 7;
                                }
                                else if(DateTime.now().hour == 20)
                                {
                                  currenthour = 8;
                                }
                                else if(DateTime.now().hour == 21)
                                {
                                  currenthour = 9;
                                }
                                else if(DateTime.now().hour == 22)
                                {
                                  currenthour = 10;
                                }
                                else if(DateTime.now().hour == 23)
                                {
                                  currenthour = 11;
                                }
                                AMorPM = "PM";
                              }
                              outgoing(output!['uid'], map['Phone'], map['Fullname'], map['profileImage'], 'Audio', DateTime.now(), currenthour.toString() + ":" + DateTime.now().minute.toString() + getTime());
                        });

                        await _firestore
                            .collection('users')
                            .doc(_firebaseAuth.currentUser!.uid)
                            .get()
                            .then((map) {
                              print(map['Fullname']);
                              print(map['profileImage']);
                              print(map['Phone']);
                              String AMorPM = "AM";
                              int currenthour = 0;
                              if (DateTime.now().hour < 12)
                              {
                                if(DateTime.now().hour == 0)
                                {
                                  currenthour = 12;
                                }
                                AMorPM = "AM";
                              }
                              else
                              {
                                if(DateTime.now().hour == 13)
                                {
                                  currenthour = 1;
                                }
                                else if(DateTime.now().hour == 14)
                                {
                                  currenthour = 2;
                                }
                                else if(DateTime.now().hour == 15)
                                {
                                  currenthour = 3;
                                }
                                else if(DateTime.now().hour == 16)
                                {
                                  currenthour = 4;
                                }
                                else if(DateTime.now().hour == 17)
                                {
                                  currenthour = 5;
                                }
                                else if(DateTime.now().hour == 18)
                                {
                                  currenthour = 6;
                                }
                                else if(DateTime.now().hour == 19)
                                {
                                  currenthour = 7;
                                }
                                else if(DateTime.now().hour == 20)
                                {
                                  currenthour = 8;
                                }
                                else if(DateTime.now().hour == 21)
                                {
                                  currenthour = 9;
                                }
                                else if(DateTime.now().hour == 22)
                                {
                                  currenthour = 10;
                                }
                                else if(DateTime.now().hour == 23)
                                {
                                  currenthour = 11;
                                }
                                AMorPM = "PM";
                              }
                              incoming(output!['Phone'], output!['Fullname'], output!['profileImage'], 'Out', DateTime.now(),  currenthour.toString() + ":" + DateTime.now().minute.toString() + " " + AMorPM);
                              FlutterPhoneDirectCaller.callNumber(output!['Phone']);
                        });
                      },
                      icon: Icon(Icons.call),
                    )
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: _buildMessageList(),
                    ),
                    _buildMessageInput(),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
        )
    );
  }

  Widget _buildMessageList()
  {
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text("ERROR: ${snapshot.error}");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          // Check if snapshot.data is not null and has data
          if (snapshot.data == null) {
            return Text("No data available.");
          }

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Text("No messages found.");
          }

          return ListView(
            children: docs.map<Widget>((document) => _buildMessageItem(document)).toList(),
          );
        }
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document)
  {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    var alignment = (data['senderID'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    var userColor = (data['senderID'] == _firebaseAuth.currentUser!.uid)
    ? Colors.blue : Colors.green;

    var darkmode = data['darkmode'];

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
          (data['senderID'] == _firebaseAuth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment:
          (data['senderID'] == _firebaseAuth.currentUser!.uid)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            data['image'] == '' ?
            ChatBubble(message: data['message'], usercolor: userColor, url: data['image'],)
                :
            ImageBubble(url: data['image']),
            Text(data['timestamp'].toString(),
              textAlign: data['senderID'] == _firebaseAuth.currentUser!.uid ?
              TextAlign.right
              :
              TextAlign.left,
              style: TextStyle(color: darkmode == true? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMessageInput()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [
                  Text(" "),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(

                          hintText: 'Enter message',
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none
                      ),
                    ),
                  ),

                  IconButton(
                      onPressed: () async {
                        getImage();
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)
                  ),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        await availableCameras().then(
                              (value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraPage(cameras: value, receiverUserEmail: widget.receiverUserEmail, receiverUserID: widget.receiverUserID, receiverUserName: widget.receiverUserName, receiverUserStatus: widget.receiverUserStatus,),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)
                  ),

                  //adding some space
                  SizedBox(width: 3 * .02),
                ],
              ),
            ),
          ),
          IconButton(
            color: Colors.blue,
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              size: 30,
            ),
          )

        ],
      ),
      );

  }

  Widget getProfilePicture(DocumentSnapshot document)
  {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    return CircleAvatar(
      radius: 20,
      backgroundImage: NetworkImage(data['profileImage']),
    );
  }
}
