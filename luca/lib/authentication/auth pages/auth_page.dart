import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luca/subscription/subscription.dart';
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
    final lastShownDate = prefs.getString('lastShownDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastShownDate != today) {
      prefs.setString('lastShownDate', today);
      _showSubscriptionPage();
    } else {
      setState(() {
        _skipSignIn = prefs.getBool('skipSignIn') ?? false;
      });
    }
  }

  void _showSubscriptionPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => SubscriptionPage(), transition: Transition.fadeIn)
          ?.then((_) {
        setState(() {
          _skipSignIn = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_skipSignIn) {
      return const LucaHome();
    } else {
      return Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const LucaHome();
            } else {
              return const LoginPage();
            }
          },
        ),
      );
    }
  }
}
