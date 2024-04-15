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
    MyHomePage(
    
    ),
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

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:iconly/iconly.dart';
// import 'package:luca/pages/favourite.dart';
// import 'package:luca/pages/homepage.dart';
// import 'package:luca/pages/live_wall.dart';
// import 'package:luca/pages/static/wallpapers.dart';
// import 'package:luca/pages/util/bottom_bar.dart';

// class LucaHome extends StatefulWidget {
//   const LucaHome({Key? key}) : super(key: key);

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
//     tabController = TabController(length: 4, vsync: this);
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

//   Color homeColor = const Color.fromARGB(255, 175, 202, 0);

//   Color searchColor = const Color.fromARGB(255, 59, 255, 226);
//   Color videoColor = Colors.blue;
//   Color heartColor = Colors.red;
//   Color unselectedColor = Colors.grey;
//   Color _getIndicatorColor(int page) {
//     switch (page) {
//       case 0:
//         return homeColor;
//       case 1:
//         return searchColor;
//       case 2:
//         return videoColor;
//       case 3:
//         return heartColor;
//       default:
//         return unselectedColor;
//     }
//   }

//   // @override
//   // void dispose() {
//   //   tabController.dispose();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: null,
//       body: Stack(
//         children: [
//           BottomBavBar(
//             fit: StackFit.expand,
//             icon: (width, height) => Center(
//               child: IconButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: null,
//                 icon: Icon(
//                   Icons.arrow_upward_rounded,
//                   color: Colors.white,
//                   size: width,
//                 ),
//               ),
//             ),
//             borderRadius: BorderRadius.circular(500),
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.decelerate,
//             showIcon: true,
//             width: MediaQuery.of(context).size.width * 0.75,
//             // barColor: Colors.black.computeLuminance() > 0.5
//             //     ? Colors.black
//             //     : const Color.fromARGB(255, 14, 3, 31),
//             barColor: Colors.transparent,
//             start: 2,
//             end: 0,
//             offset: 10,
//             barAlignment: Alignment.bottomCenter,
//             iconHeight: 50,
//             iconWidth: 50,
//             reverse: false,
//             hideOnScroll: true,
//             scrollOpposite: false,
//             onBottomBarHidden: () {},
//             onBottomBarShown: () {},
//             body: (context, controller) => TabBarView(
//               controller: tabController,
//               dragStartBehavior: DragStartBehavior.down,
//               physics: const BouncingScrollPhysics(),
//               children: [
//                 MyHomePage(controller: controller),
//                 // WallpaperScreen(controller: controller),
//                 // ImageScreen(),
//                 Category(),
//                 LiveWallBeta(),
//                 FavoriteImagesPage(),
//               ],
//             ),
//             child: TabBar(
//               dividerColor: Colors.transparent,
//               indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
//               controller: tabController,
//               indicator: UnderlineTabIndicator(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: BorderSide(
//                       color: _getIndicatorColor(currentPage), width: 6),
//                   insets: const EdgeInsets.fromLTRB(16, 0, 16, 8)),
//               tabs: [
//                 SizedBox(
//                   height: 58,
//                   width: 40,
//                   child: Center(
//                       child: Icon(
//                     IconlyBold.home,
//                     color: currentPage == 0 ? homeColor : unselectedColor,
//                     size: currentPage == 0 ? 32 : 28,
//                     // color: Colors.black,
//                   )),
//                 ),
//                 SizedBox(
//                   height: 58,
//                   width: 40,
//                   child: Center(
//                       child: Icon(
//                     IconlyBold.category,
//                     color: currentPage == 1 ? searchColor : unselectedColor,
//                     size: currentPage == 1 ? 32 : 28,
//                   )),
//                 ),
//                 SizedBox(
//                   height: 58,
//                   width: 40,
//                   child: Center(
//                       child: Icon(
//                     IconlyBold.video,
//                     color: currentPage == 2 ? videoColor : unselectedColor,
//                     size: currentPage == 2 ? 32 : 28,
//                   )),
//                 ),
//                 SizedBox(
//                   height: 58,
//                   width: 40,
//                   child: Center(
//                       child: Icon(
//                     IconlyBold.heart,
//                     color: currentPage == 3 ? heartColor : unselectedColor,
//                     size: currentPage == 3 ? 32 : 28,
//                   )),
//                 ),
//               ],
//             ),
//           ),
//           // Positioned(
//           //     bottom: 100,
//           //     right: 10,
//           //     left: 10,
//           //     child: Container(
//           //       width: 200,
//           //       height: 50,
//           //       color: Colors.red,
//           //     ))
//         ],
//       ),
//     );
//   }
// }
