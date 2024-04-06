import 'dart:io';

import 'package:capstone_project/group_chats/create_group/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

class AddUsers extends StatefulWidget {
  const AddUsers({Key? key}) : super(key: key);

  @override
  State<AddUsers> createState() => _AddUsersState();
}
enum SingingCharacter { email, phone, name }

class _AddUsersState extends State<AddUsers> {
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;
  final user = FirebaseAuth.instance.currentUser!;
  bool emailorphone = false;

  SingingCharacter? _character = SingingCharacter.email;
  //the value for this variable is set to false for email by default

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "Fullname": map['Fullname'],
          "email": map['email'],
          "uid": map['uid'],
        });
      });
    });
  }

  void onSearch() async {
    print(_search.text);
    setState(() {
      isLoading = true;
      print("finding user");
    });
    print(emailorphone);
    try
    {
      emailorphone ?
      await _firestore
          .collection('users')
          .where("Phone", isEqualTo: _search.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
      })
      :
      await _firestore
          .collection('users')
          .where("email", isEqualTo: _search.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
      });
    }
    catch(e)
    {
      print("Error: " + e.toString());
      isLoading = false;

    }

  }

  void onResultTap() {
    _firestore.collection('users').doc(_auth.currentUser!.uid).collection('My Users').doc(userMap!['uid']).set({
      "Fullname": userMap!['Fullname'],
      "email": userMap!['email'],
      "uid": userMap!['uid'],
      "image": userMap!['profileImage'],
      "latitude" : userMap!['latitude'],
      "longitude" : userMap!['longitude'],
      "Phone": userMap!['Phone'],
      "Status": userMap!['Status'],
    });
    _firestore.collection('users').doc(_auth.currentUser!.uid).collection('My Users').doc(_auth.currentUser!.uid).delete();

    _search.text = "";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatPage(
              receiverUserEmail: userMap!['email'],
              receiverUserID: userMap!['uid'],
              receiverUserName: userMap!['Fullname'],
              receiverUserStatus: userMap!['Status'],
            ),
      ),
    );
  }

  void displayOtherUserInfo()
  {
      print(userMap!['Fullname']);
      print(userMap!['email']);
      print(userMap!['uid']);
      print(userMap!['profileImage']);
      print(userMap!['Phone']);
      print(userMap!['Status']);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;


    return Scaffold(
      appBar: AppBar(
        title: Text("Add User"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users')
        .doc(user.uid)
        .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          var output = snapshot.data!.data();
          var statusValue = output!['Status'];
          var name = output!['Fullname'];
          var darkmode = output!['darkmode'];

          void printMyInfo()
          {
            print(output!['Fullname']);
            print(output!['Phone']);
            print(output!['Status']);
            print(output!['email']);
            print(output!['latitude']);
            print(output!['longitude']);
            print(output!['profileImage']);
            print(output!['uid']);
          }

          void addMetoUser()
          {
            _firestore.collection('users').doc(userMap!['uid']).collection('My Users').doc(_auth.currentUser!.uid).set({
              "Fullname": output!['Fullname'],
              "email": output!['email'],
              "uid": output!['uid'],
              "image": output!['profileImage'],
              "latitude" : 0,
              "longitude" : 0,
              "Phone": output!['Phone'],
              "Status": output!['Status'],
            });
            onResultTap();
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flexible(
                //   child: ListView.builder(
                //     itemCount: membersList.length,
                //     shrinkWrap: true,
                //     physics: NeverScrollableScrollPhysics(),
                //     itemBuilder: (context, index) {
                //       return ListTile(
                //         title: Text(membersList[index]['Fullname']),
                //         subtitle: Text(membersList[index]['email']),
                //       );
                //     },
                //   ),
                // ),
                // Center(
                //         child: Row(
                //           children: [
                //             Text("                                      "),
                //             Text("Email"),
                //             Switch(
                //               value: emailorphone,
                //               onChanged: (bool value) {
                //                 setState(() {
                //                   emailorphone = value;
                //                 });
                //                 print(value);
                //               },
                //             ),
                //             Text("Phone"),
                //           ],
                //         )
                // ),
                Text("Filter by", style: TextStyle(fontSize: 18)),
                ListTile(
                  title: const Text('Email'),
                  leading: Radio<SingingCharacter>(
                    value: SingingCharacter.email,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                        emailorphone = false;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Phone'),
                  leading: Radio<SingingCharacter>(
                    value: SingingCharacter.phone,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                        emailorphone = true;
                      });
                    },
                  ),
                ),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 14,
                    width: size.width / 1.15,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: emailorphone ?
                        "Search by phone"
                        :
                        "Search by email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                    onPressed: onSearch,
                    child: Text("Search"),
                ),
                isLoading ?
                Container(
                  height: size.height / 12,
                  width: size.height / 12,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
                :
                Text("Waiting for input..."),
                // ElevatedButton(
                //     onPressed: printMyInfo,
                //     child: Text("Display my info"),
                // ),
                // ElevatedButton(
                //     onPressed: displayOtherUserInfo,
                //     child: Text("Display user's info"),
                // ),
                userMap != null
                    ? ListTile(
                  onTap: addMetoUser,
                    leading: CircleAvatar(
                      backgroundImage: userMap!['profileImage'] != '' ?
                      NetworkImage(userMap!['profileImage'])
                          :
                      NetworkImage("https://cdn-icons-png.freepik.com/512/12225/12225935.png"),
                    ),
                    title: Text(userMap!['Fullname']),
                    subtitle: emailorphone ?
                      Text(userMap!['Phone'])
                    :
                      Text(userMap!['email']),
                    trailing: Icon(Icons.add),
                )
                    : SizedBox(),
              ],
            ),
          );
        }
      )
    );
  }
}
