import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// import '../utils.dart';
import '../services/auth/auth_service.dart';
import 'login_page.dart';

class StatusPage extends StatefulWidget
{
  final void Function()? onTap;
  const StatusPage({super.key, required this.onTap});
  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage>
{
  bool light1 = true;

  final user = FirebaseAuth.instance.currentUser!;
  final String online = "Online";
  final String away = "Away";
  final String do_not_disturb = "Do not Disturb";
  final String offline = "Offline";

  CollectionReference users = FirebaseFirestore.instance.collection('users');


  Future <void> StatusToOnline() async
  {
    return users.doc(user.uid).update({"Status": online})
        .then((value) => print("Status updated to ONLINE"))
        .catchError((onError) => print("Update failed..."));
  }

  Future <void> StatusToAway() async
  {
    return users.doc(user.uid).update({"Status": away})
        .then((value) => print("Status updated to AWAY"))
        .catchError((onError) => print("Update failed..."));
  }

  Future <void> StatusToDND() async
  {
    return users.doc(user.uid).update({"Status": do_not_disturb})
        .then((value) => print("Status updated to DO NOT DISTURB"))
        .catchError((onError) => print("Update failed..."));
  }
  Future <void> StatusToOffline() async
  {
    return users.doc(user.uid).update({"Status": offline})
        .then((value) => print("Status updated to OFFLINE"))
        .catchError((onError) => print("Update failed..."));
  }

  Future <void> readStatus()
  {
      return users.get()
          .then((QuerySnapshot snapshot) {
            snapshot.docs.forEach((doc) {
              print("");
            });
      })
      .catchError((error) => print("Failed to fetch users: $error"));
  }



  @override
  Widget build(BuildContext context)
  {
    Uint8List? _image;
    Color? backgroundcolor = light1 ? Colors.grey[900] : Colors.white;
    Color textColor = light1 ? Colors.white : Colors.black;
    Color? cardColor = light1 ? Colors.grey[800] : Colors.grey[400];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundcolor,
        appBar: AppBar(
          title: Text("Change Status"),
        ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users')
            .doc(user.uid)
            .snapshots(),
        builder:(context, snapshot)
          {
            if(!snapshot.hasData)
            {
              return const CircularProgressIndicator();
            }
            var output = snapshot.data!.data();
            var statusValue = output!['Status'];
            var darkmode = output!['darkmode'];

            return Scaffold(
              backgroundColor: darkmode == true? Colors.grey[900] : Colors.white,
              body: Center(
                child: Column(
                  children: [
                    Card(
                      color: Colors.green[500],
                      child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text('Online', style: TextStyle(color: Colors.green[800])),
                          onTap: StatusToOnline
                      ),
                    ),
                    Card(
                      color: Colors.yellow[500],
                      child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text('Away', style: TextStyle(color: Colors.yellow[800])),
                          onTap: StatusToAway
                      ),
                    ),
                    Card(
                      color: Colors.red[500],
                      child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text('Do not Disturb', style: TextStyle(color: Colors.red[800])),
                          onTap: StatusToDND
                      ),
                    ),
                    Card(
                      color: Colors.grey[500],
                      child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text('Offline', style: TextStyle(color: Colors.grey[800])),
                          onTap: StatusToOffline
                      ),
                    ),

                    Text("Current Status: " + statusValue.toString(),
                        style: TextStyle(color: darkmode == true? Colors.white : Colors.black, fontSize: 18)),
                  ],
                ),
              ),
            );
          }
      )
    );
  }
}
