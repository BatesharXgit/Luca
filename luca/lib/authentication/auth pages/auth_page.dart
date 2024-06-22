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
  bool _showSubscriptionPage = false;

  @override
  void initState() {
    super.initState();
    _checkPreferences();
  }

  Future<void> _checkPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownDate = prefs.getString('lastShownDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final hasSignedIn = prefs.getBool('hasSignedIn') ?? false;

    if (lastShownDate != today) {
      prefs.setString('lastShownDate', today);
      setState(() {
        _showSubscriptionPage = true;
      });
    }

    if (hasSignedIn) {
      setState(() {
        _skipSignIn = true;
      });
    }
  }

  void _onSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSignedIn', true);
    setState(() {
      _skipSignIn = true;
    });
    if (_showSubscriptionPage) {
      _showSubscriptionPageMethod();
    }
  }

  void _showSubscriptionPageMethod() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => SubscriptionPage(), transition: Transition.fadeIn)
          ?.then((_) {
        _setSubscriptionShown();
      });
    });
  }

  Future<void> _setSubscriptionShown() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('lastShownDate', today);
    setState(() {
      _showSubscriptionPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_skipSignIn) {
      if (_showSubscriptionPage) {
        _showSubscriptionPageMethod();
      }
      return const LucaHome();
    } else {
      return Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _onSignIn();
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
