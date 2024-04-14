import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:luca/pages/favourite.dart';
import 'package:luca/pages/homepage.dart';
import 'package:luca/pages/live_wall.dart';
import 'package:luca/pages/static/wallpapers.dart';

class LucaHome extends StatefulWidget {
  const LucaHome({super.key});

  @override
  State<LucaHome> createState() => _LucaHomeState();
}

class _LucaHomeState extends State<LucaHome> {
  int selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _pages = [
    MyHomePage(),
    Category(),
    LiveWallBeta(),
    FavoriteImagesPage(),
  ];

  _changeTab(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: IndexedStack(
      //   index: selectedPageIndex,
      //   children: _pages.map((page) {
      //     if (page == null) {
      //       return Container();
      //     } else {
      //       return page;
      //     }
      //   }).toList(),
      // ),
      body: _pages[selectedPageIndex],
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        height: 64,
        backgroundColor: Color(0xff131321),
        indicatorColor: Color(0xFFE6EDFF),
        selectedIndex: selectedPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (index) => _changeTab(index),
        destinations: <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(
              IconlyBold.home,
              size: 28,
              color: Color(0xff131321),
            ),
            icon: Icon(
              IconlyLight.home,
              size: 28,
              color: Color(0xFFE6EDFF).withOpacity(0.6),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              IconlyBold.category,
              color: Color(0xff131321),
              size: 28,
            ),
            icon: Icon(
              IconlyLight.category,
              size: 28,
              color: Color(0xFFE6EDFF).withOpacity(0.6),
            ),
            label: 'Collections',
          ),
          NavigationDestination(
            selectedIcon:
                Icon(IconlyBold.folder, color: Color(0xff131321), size: 28),
            icon: Icon(
              IconlyLight.folder,
              color: Color(0xFFE6EDFF).withOpacity(0.6),
              size: 28,
            ),
            label: 'Stock',
          ),
          NavigationDestination(
            selectedIcon:
                Icon(IconlyBold.heart, color: Color(0xff131321), size: 28),
            icon: Icon(
              IconlyLight.heart,
              color: Color(0xFFE6EDFF).withOpacity(0.6),
              size: 28,
            ),
            label: 'Favourites',
          ),
        ],
      ),
    );
  }
}
