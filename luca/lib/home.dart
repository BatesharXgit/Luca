import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:luca/pages/favourite.dart';
import 'package:luca/pages/homepage.dart';
import 'package:luca/pages/searchresult.dart';
import 'package:luca/pages/settings.dart';
import 'package:luca/pages/static/stock_categories.dart';

class LucaHome extends StatefulWidget {
  const LucaHome({super.key});

  @override
  _LucaHomeState createState() => _LucaHomeState();
}

class _LucaHomeState extends State<LucaHome> {
  int _currentIndex = 0;

  List<Widget> _pages = [
    MyHomePage(),
    SearchWallpaper(),
    // Categories(),
    StockCategories(),
    FavoriteImagesPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserProfileData();
  }

  String? userPhotoUrl;
  Future<void> fetchUserProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userPhotoUrl = user.photoURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: backgroundColor));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 48,
        child: CustomNavigationBar(
          blurEffect: true,
          iconSize: 32.0,
          selectedColor: primaryColor,
          strokeColor: Colors.transparent,
          unSelectedColor: secondaryColor,
          backgroundColor: backgroundColor,
          items: [
            CustomNavigationBarItem(
              icon: Icon(IconlyBold.home),
            ),
            CustomNavigationBarItem(
              icon: Icon(IconlyBold.search),
            ),
            CustomNavigationBarItem(
              icon: Icon(Icons.phone_android),
            ),
            CustomNavigationBarItem(
              icon: Icon(IconlyBold.heart),
            ),
            CustomNavigationBarItem(
              icon: userPhotoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                          height: 34, width: 34, imageUrl: userPhotoUrl!))
                  : Icon(IconlyBold.profile),
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
