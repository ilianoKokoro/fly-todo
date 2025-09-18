import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fly_todo/screens/auth_screen.dart';
import 'package:fly_todo/screens/home_screen.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint("Loading auth");
          return const CircularProgressIndicator();
        }
        if (snapshot.data != null) {
          debugPrint("User logged in");
          debugPrint(snapshot.data.toString());
          return const HomeScreen();
        }
        debugPrint("User not logged in");
        return const AuthScreen();
      },
    );
  }
}
