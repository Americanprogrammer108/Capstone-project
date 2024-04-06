import 'package:capstone_project/group_chats/create_group/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}
enum SingingCharacter { email, phone, name }
class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;
  bool emailorphone = false;
  SingingCharacter? _character = SingingCharacter.email;

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
          "image": map['profileImage']
        });
      });
    });
  }

  void onSearch() async {
    print(_search.text);
    setState(() {
      isLoading = true;
    });

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

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "Fullname": userMap!['Fullname'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "image": userMap!['profileImage'],
          // "isAdmin": false,
        });

        userMap = null;
      });
    }
    _search.text = "";
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => onRemoveMembers(index),
                    leading: CircleAvatar(
                      backgroundImage: membersList[index]['image'] != '' ?
                      NetworkImage(membersList[index]['image'])
                          :
                      NetworkImage("https://cdn-icons-png.freepik.com/512/12225/12225935.png"),
                    ),
                    title: Text(membersList[index]['Fullname']),
                    subtitle: Text(membersList[index]['email']),
                    trailing: Icon(Icons.close),
                  );
                },
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            // Center(
            //     child: Row(
            //       children: [
            //         Text("                                      "),
            //         Text("Email"),
            //         Switch(
            //           value: emailorphone,
            //           onChanged: (bool value) {
            //             setState(() {
            //               emailorphone = value;
            //             });
            //             print(value);
            //           },
            //         ),
            //         Text("Phone"),
            //       ],
            //     )
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
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: onSearch,
                    child: Text("Search"),
                  ),
            userMap != null
                ? ListTile(
                onTap: onResultTap,
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
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
              child: Icon(Icons.forward),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateGroup(
                    membersList: membersList,
                  ),
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
