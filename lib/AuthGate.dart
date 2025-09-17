import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'HomeScreen.dart';
// 1) AuthGate (paste your class here)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // if (snapshot.hasData) {
        //   return const HomeScreen();       // signed in
           return const EntryScreen();
        // }
        // return Text("data");
        // return const EntryScreen();       // not signed in
      },
    );
  }
}