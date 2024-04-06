import 'package:capstone_project/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';

import '../Components/my_button.dart';
import '../Components/my_text_field.dart';
import '../utils/color_utils.dart';
import 'homepage.dart';
import 'login_page.dart';
import 'package:capstone_project/services/auth/auth_service.dart';


class RegisterPage extends StatefulWidget
{
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
{
  final user = FirebaseAuth.instance.currentUser;
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  //default status is online
  final String status = "Online";
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future <void> signUp() async
  {
    print("Password: " + passwordController.text);
    print("Email: " + emailController.text);
    print("Name: " + fullNameController.text);
    print("Phone: " + phoneNumberController.text);
    //pass validation
    if (fullNameController.text == "" || phoneNumberController.text == "" ||
        passwordController.text == "" || emailController.text == "")
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required!")));
    }
    else if(!contains(emailController.text, "@"))
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This is not a valid email!")));
    }
    else if(passwordController.text.length < 8)
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password must be 8 or more characters!")));
    }
    else
    {
      //if validation is successful,
      if (passwordController.text != confirmPasswordController.text)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PASSWORDS DO NOT MATCH!"),
          ),
        );
        return;
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      try
      {
        print("Attempt to create user");
        await authService.signUpWithEmailandPassword(
            emailController.text,
            passwordController.text,
            fullNameController.text,
            phoneNumberController.text,
            status
        );

        print("Registration successful");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(onTap: () {  },),
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
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text("Register",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    )
                ),
                const SizedBox(height: 50),
                MyTextField(controller: fullNameController, hintText: 'Full Name', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: phoneNumberController, hintText: 'Phone Number', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
                const SizedBox(height: 10),
                MyTextField(controller: passwordController, hintText: 'Password', obscureText: true),
                const SizedBox(height: 10),
                MyTextField(controller: confirmPasswordController, hintText: 'Confirm Password', obscureText: true),
                const SizedBox(height: 20),
                MyButton(onTap: signUp, text: "Register"),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: ()
                  {
                    // Navigate to the login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(onTap: () {  },),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 6, 112, 77),
                  ),
                  child: const Text("Already registered? Click here to sign in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
