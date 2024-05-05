import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luca/pages/favourite.dart';
import 'package:luca/pages/homepage.dart';
import 'package:luca/pages/static/categories.dart';
import 'package:luca/pages/static/stock_categories.dart';
import 'package:luca/pages/util/bottom_bar.dart';
import 'package:luca/pages/util/tab_bar_test.dart';

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

//   Color unselectedColor = Colors.grey;

//   // @override
//   // void dispose() {
//   //   tabController.dispose();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: null,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             BottomBar(
//               fit: StackFit.expand,
//               icon: (width, height) => Center(
//                 child: IconButton(
//                   padding: EdgeInsets.zero,
//                   onPressed: null,
//                   icon: Icon(
//                     Icons.arrow_upward_rounded,
//                     color: Theme.of(context).colorScheme.background,
//                     size: width,
//                   ),
//                 ),
//               ),
//               borderRadius: BorderRadius.circular(500),
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.decelerate,
//               showIcon: true,
//               width: MediaQuery.of(context).size.width * 0.75,
//               // barColor: Colors.black.computeLuminance() > 0.5
//               //     ? Colors.black
//               //     : const Color.fromARGB(255, 14, 3, 31),
//               barColor: Theme.of(context).colorScheme.background,
//               start: 2,
//               end: 0,

//               barAlignment: Alignment.bottomCenter,
//               iconHeight: 50,
//               iconWidth: 50,
//               reverse: false,
//               hideOnScroll: true,
//               scrollOpposite: false,
//               onBottomBarHidden: () {},
//               onBottomBarShown: () {},
//               body: (context, controller) => TabBarView(
//                 controller: tabController,
//                 dragStartBehavior: DragStartBehavior.down,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   MyHomePage(controller: controller),
//                   // WallpaperScreen(controller: controller),
//                   // ImageScreen(),
//                   // const Category(),

//                   // const LiveWallBeta(),
//                   Categories(controller: controller),
//                   Categories(controller: controller),
//                   StockCategories(controller: controller),
//                   FavoriteImagesPage(controller: controller),
//                 ],
//               ),
//               child: TabBar(
//                 dividerColor: Colors.transparent,
//                 indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
//                 controller: tabController,
//                 indicator: UnderlineTabIndicator(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: const BorderSide(
//                         // color: Theme.of(context).colorScheme.background,
//                         color: Color(0xff04ff0d),
//                         width: 6),
//                     insets: const EdgeInsets.fromLTRB(20, 0, 10, 8)),
//                 tabs: [
//                   SizedBox(
//                     height: 58,
//                     width: 40,
//                     child: Center(
//                         child: Icon(
//                       IconlyBold.home,
//                       color: currentPage == 0
//                           ? const Color(0xff04ff0d)
//                           // ? Theme.of(context).colorScheme.background
//                           : unselectedColor,
//                       size: currentPage == 0 ? 32 : 28,
//                       // color: Colors.black,
//                     )),
//                   ),
//                   SizedBox(
//                     height: 58,
//                     width: 40,
//                     child: Center(
//                         child: Icon(
//                       Iconsax.category,
//                       color: currentPage == 1
//                           ? const Color(0xff04ff0d)
//                           : unselectedColor,
//                       size: currentPage == 1 ? 32 : 28,
//                     )),
//                   ),
//                   SizedBox(
//                     height: 58,
//                     width: 40,
//                     child: Center(
//                         child: Icon(
//                       Icons.smartphone,
//                       color: currentPage == 2
//                           ? const Color(0xff04ff0d)
//                           : unselectedColor,
//                       size: currentPage == 2 ? 32 : 28,
//                     )),
//                   ),
//                   SizedBox(
//                     height: 58,
//                     width: 40,
//                     child: Center(
//                         child: Icon(
//                       Icons.computer_outlined,
//                       color: currentPage == 3
//                           ? const Color(0xff04ff0d)
//                           : unselectedColor,
//                       size: currentPage == 3 ? 32 : 28,
//                     )),
//                   ),
//                   SizedBox(
//                     height: 58,
//                     width: 40,
//                     child: Center(
//                         child: Icon(
//                       IconlyBold.heart,
//                       color: currentPage == 4
//                           ? const Color(0xff04ff0d)
//                           : unselectedColor,
//                       size: currentPage == 4 ? 32 : 28,
//                     )),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class LucaHome extends StatefulWidget {
  @override
  _LucaHomeState createState() => _LucaHomeState();
}

class _LucaHomeState extends State<LucaHome> {
  int _currentIndex = 0;

  List<Widget> _pages = [
    MyHomePage(),
    Categories(),
    Categories(),
    StockCategories(),
    FavoriteImagesPage(),
  ];

  @override
  void initState() {
    super.initState();
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
      bottomNavigationBar: CustomNavigationBar(
        iconSize: 30.0,
        selectedColor: primaryColor,
        strokeColor: Colors.transparent,
        unSelectedColor: secondaryColor,
        backgroundColor: backgroundColor,
        items: [
          CustomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          CustomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
          ),
          CustomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
          ),
          CustomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          CustomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
