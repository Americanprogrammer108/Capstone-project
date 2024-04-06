import 'dart:io' as io;

import 'package:capstone_project/group_chats/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../services/chat/image_chat_service.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageChatService _imageChatService = ImageChatService();
  io.File? imageFile;

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
    return DateTime.now().month.toString() + "-" + DateTime.now().day.toString() + "-" + DateTime.now().year.toString() + " " + currenthour.toString() + ":" + DateTime.now().minute.toString() + AMorPM;
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.email,
        "message": _message.text,
        "type": "text",
        "time": getTime(),
        "image": '',
        "timestamp": DateTime.now(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  void sendImageMessage(String url) async
  {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.email,
        "message": _message.text,
        "type": "image",
        "time": getTime(),
        "image" : url,
        "timestamp": DateTime.now()
      };

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    print(url);
    _message.clear();
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupInfo(
                        groupId: groupChatId,
                        groupName: groupName,
                      ),
                    ),
                  ),
              icon: Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.27,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(groupChatId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> chatMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                        return messageTile(size, chatMap);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                getImage();
                              },
                              icon: Icon(Icons.photo, color: Colors.blueAccent),
                            ),
                            hintText: "Send Message",
                            hintStyle: TextStyle(color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send), onPressed: onSendMessage, color: Colors.blueAccent,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.email
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment:
              (chatMap['senderID'] == _auth.currentUser!.uid)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              mainAxisAlignment:
              (chatMap['senderID'] == _auth.currentUser!.uid)
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: chatMap['sendBy'] == _auth.currentUser!.email ?
                      Colors.blue
                      :
                      Colors.green,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height / 200,
                        ),
                        Text(
                          chatMap['message'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                ),
                Text(
                  chatMap['sendBy'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  chatMap['time'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                ""
                ),
              ],
            ),
          ),
        );
      } else if (chatMap['type'] == "image") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.email
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment:
              (chatMap['senderID'] == _auth.currentUser!.uid)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              mainAxisAlignment:
              (chatMap['senderID'] == _auth.currentUser!.uid)
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: chatMap['sendBy'] == _auth.currentUser!.email ?
                      Colors.blue
                          :
                      Colors.green,
                    ),
                    height: size.height /2.35,
                    width: size.height /3,
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height / 200,
                        ),
                        Image.network(
                          chatMap['image'],
                        ),
                      ],
                    )
                ),
                Text(
                  chatMap['sendBy'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  chatMap['time'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                    ""
                ),
              ],
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.email
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment:
              (chatMap['senderID'] == _auth.currentUser!.uid)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              mainAxisAlignment:
              (chatMap['senderID'] == _auth.currentUser!.uid)
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.black38,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height / 200,
                        ),
                        Text(
                          chatMap['message'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                ),
                Text(
                  chatMap['sendBy'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  chatMap['time'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                    ""
                ),
              ],
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }
}
