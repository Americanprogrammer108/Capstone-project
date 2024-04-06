import 'package:capstone_project/Components/my_button.dart';
import 'package:capstone_project/Components/my_text_field.dart';
import 'package:capstone_project/pages/register_page.dart';
import 'package:capstone_project/pages/reset_password.dart';
import 'package:capstone_project/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/color_utils.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget
{
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  final user = FirebaseAuth.instance.currentUser;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn()
  async {
    final authService = Provider.of<AuthService>(context, listen: false);
    print(emailController.text);
    print(passwordController.text);
    try
    {
      if (emailController.text == "" || passwordController.text == "")
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Both fields are required!")));
      }
      else
      {
        try
        {
          await authService.signInWithEmailandPassword(
              emailController.text,
              passwordController.text
          );
          print("Login successful");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
        catch(e)
        {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("That user does not exist.")));
        }

      }
      //does not exist?

    }
    catch (e)
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(),),),);
      print(e.toString());
    }
  }




  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
        hexStringToColor("0000FF"),
        hexStringToColor("00FFFF"),
        hexStringToColor("00FF00")
        ],begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: Padding(
              // itemCount: data.length,
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const SizedBox(height: 50),
                  const SizedBox(height: 50),
                  const SizedBox(height: 50),
                  Text("Login",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      )
                  ),
                  const SizedBox(height: 50),
                  MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
                    const SizedBox(height: 10),
                  MyTextField(controller: passwordController, hintText: 'Password', obscureText: true),
                  const SizedBox(height: 20),
                  MyButton(onTap: signIn, text: "Sign In"),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: ()
                    {
                      // Navigate to the login page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(onTap: () {  },),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 6, 112, 77),
                    ),
                    child: const Text("New user? Click here to register!"),
                  ),

                  TextButton(
                    onPressed: ()
                    {
                      // Navigate to the login page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 6, 112, 77),
                    ),
                    child: const Text("Forgot password? Click here!"),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
