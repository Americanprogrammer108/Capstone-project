import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AuthService extends ChangeNotifier
{
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailandPassword
  (String email, password) async
  {
    try
    {
      print("Logging in...");
      //sign in
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
      );

      print("Finishing up...");

      //add a new document for the user in users collection if it doesn't exist
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));
      return userCredential;
    }
    on FirebaseAuthException catch (e)
    {
      throw Exception("Exception 404: " + e.code);
    }
  }

  // create a new user
  Future<UserCredential> signUpWithEmailandPassword
  (String _email, String _password, String _fullName, String _phone, String _stats) async
  {
    try {
      print("Creating user...");
      //sign up
      print("Email: " + _email);
      print("Password: " + _password);
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      //ends here

      print("Finishing up...");

      var doubleValueLat, doubleValueLong = Random().nextDouble(); // Value is >= 0.0 and < 1.0.
      doubleValueLat = Random().nextDouble() * 128;
      doubleValueLong = Random().nextDouble() * 128;

      print("ON it...");
      //add a new document for the user in users collection if it doesn't exist
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': _email,
        'Fullname': _fullName,
        'Phone': _phone,
        'profileImage': "",
        'Status': _stats,
        'latitude': doubleValueLat,
        'longitude': doubleValueLong,
        'darkmode': false,
      });

      print("Registration successful.");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Error 404: " + e.code);
    }
  }



  //   sign user out
  Future<void> signOut() async
  {
    return await FirebaseAuth.instance.signOut();
  }

}