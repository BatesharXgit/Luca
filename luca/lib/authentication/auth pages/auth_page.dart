import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luca/authentication/auth%20pages/login_page.dart';
import 'package:luca/home.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _skipSignIn = false;

  @override
  void initState() {
    super.initState();
    _checkSkipSignIn();
  }

  Future<void> _checkSkipSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _skipSignIn = prefs.getBool('skipSignIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_skipSignIn) {
      return LucaHome();
    } else {
      return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return LucaHome();
              } else {
                return const LoginPage();
              }
            }),
      );
    }
  }
}
