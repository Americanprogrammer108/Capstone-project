import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget
{
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

 @override
 Widget build(BuildContext context)
 {
   return TextField(
     controller: controller,
     obscureText: obscureText,
     cursorColor: Colors.white,
     decoration: InputDecoration(
       enabledBorder: OutlineInputBorder
         (
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid),
       ),
       focusedBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(30.0),
         borderSide: BorderSide(color: Colors.black),
       ),
       fillColor: Colors.white.withOpacity(0.3),
       filled: true,
       hintText: hintText,
       hintStyle: const TextStyle(color: Colors.grey),
       ),

   );
 }
}