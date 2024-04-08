import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luca/authentication/auth%20pages/login_page.dart';
import 'package:luca/home.dart';
import 'package:luca/pages/homepage.dart';

import '../../test_home.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const LucaHome(
                  // title: '',
                  );
              // return const MyHomePage();
              // return WallpaperUploaderScreen();
            } else {
              return const LoginPage();
            }
          }),
    );
  }
}
