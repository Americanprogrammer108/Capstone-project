import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
{
  final emailController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Map<String, dynamic>? userMap;

  @override
  void dispose()
  {
    emailController.dispose();
    super.dispose();
  }

  Future <void> passwordReset() async
  {
    try
    {
      if (emailController.text == "")
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter an email!"),
          ),
        );
      }
      else if (!emailController.text.contains("@"))
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This is not a valid email!"),
          ),
        );
      }
      else
      {
        print("on it...");
        userMap?.clear();
        await FirebaseFirestore.instance
            .collection('users')
            .where("email", isEqualTo: emailController.text)
            .get()
            .then((value) async {
            try
            {
              userMap = value.docs[0].data();
              await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
              // showDialog(context: context, builder: (context) {
              //   return AlertDialog(
              //       content: Text("Password reset link sent! Check your email.")
              //   );
              // });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password reset link sent! Check your email."),
                ),
              );
            }
            catch(e)
            {
              print("Error: " + e.toString());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("The email that was entered does not exist."),
                ),
              );
            }
          });
          print(userMap);
      }
    }
    on FirebaseAuthException catch (e)
    {
      print(e.toString());
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Text(e.message.toString()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
        body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
        hexStringToColor("0000FF"),
        hexStringToColor("00FFFF"),
        hexStringToColor("00FF00")
    ],begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Enter your email and we will send you a link to reset your password",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                  ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      hintText: "Email",
                      fillColor: Colors.white.withOpacity(0.3),
                      filled: true,
                    ),
                  ),
                ),

                MaterialButton(
                  onPressed: passwordReset,
                  child: Text("Reset Password"),
                  color: Colors.deepPurple[200],

                ),
              ],
            ),
          ),
        ),
    );
  }
}
