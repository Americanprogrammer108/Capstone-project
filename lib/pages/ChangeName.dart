import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:capstone_project/services/auth/auth_service.dart';

import '../Components/my_button.dart';
import '../Components/my_text_field.dart';
import '../services/auth/auth_service.dart';
import '../utils.dart';
import 'Status.dart';
import 'login_page.dart';

class ChangeNamePage extends StatefulWidget
{
  final void Function()? onTap;
  const ChangeNamePage({super.key, required this.onTap});
  @override
  State<ChangeNamePage> createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage>
{
  bool light1 = true;
  final user = FirebaseAuth.instance.currentUser!;
  String full_name = "";
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void updateName() async
  {
    full_name = firstNameController.text + " " + lastNameController.text;
    print(full_name);
    // _auth.currentUser!.displayName = full_name;
    return users.doc(user.uid).update({"Fullname": full_name})
        .then((value) => print("Name changed to " + full_name))
        .catchError((onError) => print("Name change failed..."));
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
        title: Text("Edit Name"),
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
            var fullname = output!['Fullname'];
            var darkmode = output!['darkmode'];

            return Scaffold(
              backgroundColor: darkmode == true? Colors.grey[800] : Colors.white,
              body: Center(
                child: Column(
                  children: [
                    Text("Current Name: " + fullname.toString(), style: TextStyle(color: darkmode == true? Colors.white : Colors.grey[800]),),
                    const SizedBox(height: 50),
                    MyTextField(controller: firstNameController, hintText: 'First Name', obscureText: false),
                    const SizedBox(height: 10),
                    MyTextField(controller: lastNameController, hintText: 'Last Name', obscureText: false),
                    const SizedBox(height: 10),
                    MyButton(onTap: updateName, text: "Update Name"),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}

