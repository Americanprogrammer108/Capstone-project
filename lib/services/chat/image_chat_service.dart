import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/image_message.dart';
import '../../model/message.dart';

class ImageChatService extends ChangeNotifier
{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //SEND MESSAGE
  Future<void> sendMessage(String receiverID, String imageurl) async
  {
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
      return currenthour.toString() + ":" + DateTime.now().minute.toString() + AMorPM;
    }

    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final String message = '';
    final bool isSeen = false;

    ImageMessage newImageMessage = ImageMessage(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      timestamp: getTime(),
      url: imageurl,
      isSeen: isSeen,
      message: message,
      time: Timestamp.now(),
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join(
      "_");

    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newImageMessage.toMap());
  }

  //send image message
  Future<void> sendImageMessage(String receiverID, String url) async
  {
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    final bool isSeen = false;
    final String message = '';

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

    ImageMessage newImageMessage = ImageMessage(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        timestamp: getTime(),
        url: url,
        isSeen: isSeen,
        message: '',
        time: Timestamp.now(),
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join(
        "_");

    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newImageMessage.toMap()
    );
  }

  //GET MESSAGES
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID)
  {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}