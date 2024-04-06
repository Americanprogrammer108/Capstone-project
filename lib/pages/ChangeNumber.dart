import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Components/my_button.dart';
import '../Components/my_text_field.dart';
import '../services/auth/auth_service.dart';
import '../utils.dart';
import 'Status.dart';
import 'login_page.dart';

class ChangeNumberPage extends StatefulWidget
{
  final void Function()? onTap;
  const ChangeNumberPage({super.key, required this.onTap});
  @override
  State<ChangeNumberPage> createState() => _ChangeNumberPageState();
}

class _ChangeNumberPageState extends State<ChangeNumberPage>
{
  bool light1 = true;
  final user = FirebaseAuth.instance.currentUser!;
  final phoneNumberController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');


  Future <void> updateNumber() async
  {
    return users.doc(user.uid).update({"Phone": phoneNumberController.text})
        .then((value) => print("Phone number updated!"))
        .catchError((onError) => print("Update failed..."));
  }

  @override
  Widget build(BuildContext context)
  {
    Color? backgroundcolor = light1 ? Colors.grey[900] : Colors.white;
    Color textColor = light1 ? Colors.white : Colors.black;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        title: Text("Edit Phone Number"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users')
          .doc(user.uid)
          .snapshots(),
          builder:(context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            var output = snapshot.data!.data();
            var phoneNumber = output!['Phone'];
            var darkmode = output!['darkmode'];

          return Scaffold(
            backgroundColor: darkmode == true? Colors.grey[800] : Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Current Number: " + phoneNumber.toString(), style: TextStyle(color: darkmode == true? Colors.white : Colors.grey[800])),
                  const SizedBox(height: 50),
                  MyTextField(controller: phoneNumberController, hintText: 'Phone Number', obscureText: false),
                  const SizedBox(height: 10),
                  MyButton(onTap: updateNumber, text: "Update Phone Number"),

                ],
              ),
            )
          );
        }
      ),
    );
  }
}

