import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luca/pages/favourite.dart';
import 'package:luca/pages/homepage.dart';
import 'package:luca/pages/live_wall.dart';
import 'package:luca/pages/settings.dart';
import 'package:luca/pages/static/wallpapers.dart';

// class LucaHome extends StatefulWidget {
//   const LucaHome({Key? key, required this.title}) : super(key: key);
//   final String title;

//   @override
//   LucaHomeState createState() => LucaHomeState();
// }

// class LucaHomeState extends State<LucaHome>
//     with SingleTickerProviderStateMixin {
//   late int currentPage;
//   late TabController tabController;

//   @override
//   void initState() {
//     currentPage = 0;
//     tabController = TabController(length: 5, vsync: this);
//     tabController.animation!.addListener(
//       () {
//         final value = tabController.animation!.value.round();
//         if (value != currentPage && mounted) {
//           changePage(value);
//         }
//       },
//     );
//     super.initState();
//   }

//   void changePage(int newPage) {
//     setState(() {
//       currentPage = newPage;
//     });
//   }

//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor = Theme.of(context).colorScheme.tertiary;
//     Color primaryColor = Theme.of(context).colorScheme.primary;
//     return Scaffold(
//       body: BottomBar(
//         borderRadius: BorderRadius.circular(500),
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.decelerate,
//         showIcon: true,
//         width: MediaQuery.of(context).size.width * 0.8,
//         barColor: backgroundColor,
//         iconHeight: 35,
//         iconWidth: 35,
//         reverse: false,
//         hideOnScroll: false,
//         body: (context, controller) => TabBarView(
//           controller: tabController,
//           dragStartBehavior: DragStartBehavior.down,
//           physics: const NeverScrollableScrollPhysics(),
//           children: const [
//             MyHomePage(),
//             Category(),
//             LiveWallBeta(),
//             FavoriteImagesPage(),
//             SettingsPage(),
//           ],
//         ),
//         child: TabBar(
//           dividerColor: Colors.transparent,
//           indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
//           controller: tabController,
//           indicator: UnderlineTabIndicator(
//               borderSide: BorderSide(color: primaryColor, width: 4),
//               insets: const EdgeInsets.fromLTRB(16, 0, 16, 8)),
//           tabs: [
//             SizedBox(
//               height: 55,
//               width: 40,
//               child: Center(
//                   child: Icon(
//                 Iconsax.home_1,
//                 color: primaryColor,
//               )),
//             ),
//             SizedBox(
//               height: 55,
//               width: 40,
//               child: Center(
//                   child: Icon(
//                 Iconsax.image4,
//                 color: primaryColor,
//               )),
//             ),
//             SizedBox(
//               height: 55,
//               width: 40,
//               child: Center(
//                   child: Icon(
//                 Iconsax.video_circle,
//                 color: primaryColor,
//               )),
//             ),
//             SizedBox(
//               height: 55,
//               width: 40,
//               child: Center(
//                   child: Icon(
//                 Iconsax.heart,
//                 color: primaryColor,
//               )),
//             ),
//             SizedBox(
//               height: 55,
//               width: 40,
//               child: Center(
//                   child: Icon(
//                 Iconsax.setting_2,
//                 color: primaryColor,
//               )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class LucaHome extends StatefulWidget {
  @override
  _LucaHomeState createState() => _LucaHomeState();
}

class _LucaHomeState extends State<LucaHome> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    MyHomePage(),
    Category(),
    LiveWallBeta(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.heart,
                  text: 'Likes',
                ),
                GButton(
                  icon: LineIcons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
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
