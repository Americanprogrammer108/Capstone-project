import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/call.dart';
import '../../model/message.dart';

class CallService extends ChangeNotifier
{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //SEND MESSAGE
  Future<void> makeCall(String receiverID, String fullname, String image, String time, String datenow) async
  {
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    final bool isSeen = false;

    Call newCall = Call(
      name: fullname,
      timestamp: time,
      date: datenow,
      image: '',
      time: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join(
        "_");

    await _fireStore
        .collection('users')
        .doc(currentUserID)
        .collection('Missed calls')
        .add(newCall.toMap());
  }

  Future<void> receiveCall(String receiverID, String fullname, String image, String time, String datenow) async
  {
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Call newCall = Call(
      name: fullname,
      timestamp: time,
      date: datenow,
      image: '',
      time: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join(
        "_");

    await _fireStore
        .collection('users')
        .doc(currentUserID)
        .collection('Missed calls')
        .add(newCall.toMap());
  }

}