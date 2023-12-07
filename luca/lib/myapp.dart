import 'package:flutter/material.dart';
import 'package:luca/pages/favourite.dart';
import 'package:luca/pages/homepage.dart';
import 'package:luca/pages/live_wall.dart';
import 'package:luca/pages/static/wallpapers.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class LucaHome extends StatefulWidget {
  const LucaHome({super.key});

  @override
  LucaHomeState createState() => LucaHomeState();
}

class LucaHomeState extends State<LucaHome> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    MyHomePage(),
    Category(),
    LiveWallBeta(),
    FavoriteImagesPage()
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: null,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: tertiaryColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              backgroundColor: tertiaryColor,
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: const Color.fromARGB(255, 175, 202, 0),
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: backgroundColor,
              color: Colors.grey,
              tabs: const [
                GButton(
                  iconSize: 26,
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  iconSize: 26,
                  icon: LineIcons.compass,
                  text: 'Explore',
                ),
                GButton(
                  iconSize: 26,
                  icon: LineIcons.video,
                  text: 'Live',
                ),
                GButton(
                  iconSize: 26,
                  icon: LineIcons.heart,
                  text: 'Liked',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
