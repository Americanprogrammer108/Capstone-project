import 'dart:typed_data';
import 'dart:io';
import 'package:capstone_project/pages/ChangeNumber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_service.dart';
import '../utils.dart';
import 'ChangeName.dart';
import 'Status.dart';
import 'login_page.dart';

class EditPage extends StatefulWidget
{
  final void Function()? onTap;
  final Color? cardColor;
  final Color textColor;
  final Color? navbarcolor;
  final Color? appbarcolor;
  const EditPage({super.key, required this.onTap,
    required this.cardColor, required this.textColor, required this.navbarcolor, required this.appbarcolor
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage>
{
  // final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool light1 = true;
  final user = FirebaseAuth.instance.currentUser!;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Uint8List? _image;
  String imageUrl = "";

  void selectImage() async
  {
    final img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
    print("Image: " + _image.toString());
  }
  
  void pickUploadImage() async
  {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    Reference ref = FirebaseStorage.instance.ref().child("profilepic.jpg");

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value){
      print(value);
      setState(() {
        imageUrl = value;
      });
    });
  }

  @override
  Widget build(BuildContext context)
  {
    Uint8List? _image;
    Color? backgroundcolor = light1 ? Colors.grey[900] : Colors.white;
    Color textColor = light1 ? Colors.white : Colors.black;
    Color? cardColor = light1 ? Colors.grey[800] : Colors.grey[400];
    final user = FirebaseAuth.instance.currentUser!;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    String imageURL = '';

    void deleteAccount() async
    {
      final authService = Provider.of<AuthService>(context, listen: false);
      try
      {
        print("Deleting user...");
        

        print("Delete successful");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(onTap: () {},),
          ),
        );
      }
      catch (e)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: " + e.toString()),
          ),
        );
        print("Error: " + e.toString());
      }
    }

    void signOut() {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.signOut();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        title: Text("Edit Account Details"),
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
          var name = output!['Fullname'];
          var status = output!['Status'];
          var email = output!['email'];
          var darkmode = output!['darkmode'];

          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: darkmode == true? Colors.grey[900] : Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  imageURL != null ?
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(output!['profileImage'])
                  ):
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage("https://i.pinimg.com/originals/a8/57/00/a85700f3c614f6313750b9d8196c08f5.png"),
                  ),

                  IconButton(
                    icon: Icon(Icons.add_a_photo),
                    onPressed: () async {
                      //First step: pick an image
                      ImagePicker imagepicker = ImagePicker();
                      XFile? file = await imagepicker.pickImage(source: ImageSource.gallery);
                      print('${file?.path}');

                      if(file==null) return;
                      // import dart:core
                      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

                      //Second step: upload to firebase storage
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages = referenceRoot.child('images');

                      //Create a reference for the image to be stored
                      Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

                      //handle errors/successes
                      try
                      {
                        //store the file
                        await referenceImageToUpload.putFile(File(file!.path));
                        //Success: get the download URL
                        imageURL = await referenceImageToUpload.getDownloadURL();
                        print(imageURL);
                        return users.doc(user.uid).update({"profileImage": imageURL})
                            .then((value) => print("Profile picture updated!"))
                            .catchError((onError) => print("Update failed..."));

                      }
                      catch(e)
                      {
                        print("Error: " + e.toString());
                      }
                    // 14:51

                    },
                  ),

                  Text(name.toString(), style: TextStyle(color: darkmode == true? Colors.white : Colors.grey[900])),
                  Text(status.toString(), style: TextStyle(color: darkmode == true? Colors.white : Colors.grey[900])),
                  Text(email.toString(), style: TextStyle(color: darkmode == true? Colors.white : Colors.grey[900])),
                  Card(
                    color: darkmode == true? Colors.grey[800] : Colors.white,
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(),
                        title: Text("Change Number",
                          style: TextStyle(height: 2, fontSize: 15, color: darkmode == true? Colors.white : Colors.grey[900] ),
                        ),
                        //status should be displayed here
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNumberPage(onTap: () {  },),
                            ),
                          );
                        }
                    ),
                  ),
                  Card(
                    color: darkmode == true? Colors.grey[800] : Colors.white,
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(),
                        title: Text("Change Name",
                          style: TextStyle(height: 2, fontSize: 15, color: darkmode == true? Colors.white : Colors.grey[900]),
                        ),
                        //status should be displayed here
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNamePage(onTap: () {  },),
                            ),
                          );
                        }
                    ),
                  ),
                  Card(
                    color: darkmode == true? Colors.grey[800] : Colors.white,
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(),
                        title: Text("Delete Account",
                          style: TextStyle(height: 2, fontSize: 15, color: darkmode == true? Colors.white : Colors.grey[900]),
                        ),
                        //status should be displayed here
                        onTap: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                title: const Text('Delete account?'),
                                content: const Text("Are you sure you want to delete your account? WARNING: All messages you sent will be erased!"),
                                actions: <Widget>
                                [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, "NO"),
                                    child: const Text("NO"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      print(output!['uid']);
                                      print(FirebaseAuth.instance.currentUser);
                                      await FirebaseFirestore.instance.collection('users').doc(output!['uid']).delete();
                                      signOut();
                                      //
                                      FirebaseAuth.instance.currentUser?.delete();
                                      //
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LoginPage(onTap: () {},),
                                        ),
                                      );
                                    },
                                    child: const Text("YES"),
                                  ),
                                ]
                            )
                        )
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

