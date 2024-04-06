import 'package:capstone_project/services/auth/login_or_register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../pages/homepage.dart';

class AuthGate extends StatelessWidget
{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot)
          {
            if (snapshot.hasData)
            {
              return const HomePage();
            }
            else
            {
              return const LoginOrRegister();
            }
          }
      ),
    );
  }
}