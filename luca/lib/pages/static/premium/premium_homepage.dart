// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:luca/pages/static/premium/premium_categories.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:luca/pages/util/apply_walls.dart';
// import 'package:luca/pages/util/components.dart';

// class PremiumCategories extends StatefulWidget {
//   const PremiumCategories({Key? key}) : super(key: key);

//   @override
//   State<PremiumCategories> createState() => PremiumCategoriesState();
// }

// class PremiumCategoriesState extends State<PremiumCategories>
//     with SingleTickerProviderStateMixin {
//   final ScrollController scrollController = ScrollController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   late TabController _tabController;

//   List<String> premiumData = [
//     'Abstract',
//     'Aesthetic',
//     'Amoled',
//     'Anime',
//     'Digital Art',
//     'Cars',
//     'Cool Walls',
//     'Dark Fantasy Art',
//     'Foods',
//     'Funny',
//     'Homescreen',
//     'Illustration',
//     'Lockscreen',
//     'Pixel Art',
//     'Pop Art',
//     'Superhero',
//     'Text Wall',
//     'Vivid Paint',
//   ];

//   List<String> _category = [
//     'Abstract',
//     'Aesthetic',
//     'Amoled',
//     'Anime',
//     'Art',
//     'Cars',
//     'Cool',
//     'Fantasy',
//     'Foods',
//     'Funny',
//     'Homescreen',
//     'Illustration',
//     'Lockscreen',
//     'PixelArt',
//     'PopArt',
//     'Superheroes',
//     'TextWall',
//     'Vivid',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: premiumData.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();
//     super.dispose();
//   }

//   Widget _buildTabViews(context) {
//     return TabBarView(
//       physics: NeverScrollableScrollPhysics(),
//       controller: _tabController,
//       children: List.generate(premiumData.length, (index) {
//         return SizedBox(
//           height: MediaQuery.of(context).size.height,
//           child: PremiumCategoriesWallpaper(
//             _category[index],
//           ),
//         );
//       }),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor = Theme.of(context).colorScheme.background;
//     Color primaryColor = Theme.of(context).colorScheme.primary;
//     Color secondaryColor = Theme.of(context).colorScheme.secondary;
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 color: Colors.red,
//                 child: Center(
//                     child: Text(
//                   'Premium wallpapers, free for a limited time',
//                   style: GoogleFonts.kanit(),
//                 )),
//               ),
//               TabBar(
//                 padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
//                 tabAlignment: TabAlignment.start,
//                 dividerColor: Colors.transparent,
//                 physics: const BouncingScrollPhysics(),
//                 indicatorPadding: const EdgeInsets.fromLTRB(0, 42, 0, 2),
//                 controller: _tabController,
//                 indicatorColor: primaryColor,
//                 labelPadding: EdgeInsets.only(right: 10, left: 10),
//                 indicator: BoxDecoration(
//                   color: primaryColor,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 labelColor: primaryColor,
//                 unselectedLabelColor: secondaryColor,
//                 isScrollable: true,
//                 tabs: premiumData.map((tab) {
//                   return Tab(
//                     child: Text(
//                       tab,
//                       style: GoogleFonts.montserrat(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               Expanded(child: _buildTabViews(context)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luca/controllers/premium_category_controller.dart';
import 'package:luca/controllers/premium_home_controller.dart';

class PremiumHomepage extends StatelessWidget {
  final PremiumHomeController controller = Get.put(PremiumHomeController());

  PremiumHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                    child: Text(
                  'Premium wallpapers',
                  style: GoogleFonts.kanit(
                    color: Theme.of(context).colorScheme.background,
                  ),
                )),
              ),
              TabBar(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                physics: const BouncingScrollPhysics(),
                indicatorPadding: const EdgeInsets.fromLTRB(0, 42, 0, 2),
                controller: controller.tabController,
                indicatorColor: primaryColor,
                labelPadding: EdgeInsets.only(right: 10, left: 10),
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                labelColor: primaryColor,
                unselectedLabelColor: secondaryColor,
                isScrollable: true,
                tabs: controller.premiumData.map((tab) {
                  return Tab(
                    child: Text(
                      tab,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: List<Widget>.generate(controller.premiumData.length,
                      (index) {
                    return CategoryPage(category: controller.category[index]);
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String category;
  CategoryPage({required this.category});

  @override
  Widget build(BuildContext context) {
    final PremiumCategoryController controller =
        Get.put(PremiumCategoryController(category), tag: category);

    return Obx(() {
      if (controller.isLoading.value &&
          controller.categoriesWallpapers.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return _buildImageGrid(controller);
    });
  }

  Widget _buildImageGrid(PremiumCategoryController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // AdHelper.showInterstitialAd(onComplete: () async {
                    //   await Get.to(
                    //     ApplyWallpaperPage(
                    //       url: controller.categoriesWallpapers[index].url,
                    //       uploaderName: controller
                    //           .categoriesWallpapers[index].uploaderName,
                    //       title: controller.categoriesWallpapers[index].title,
                    //       thumbnailUrl: controller
                    //           .categoriesWallpapers[index].thumbnailUrl,
                    //     ),
                    //     transition: Transition.downToUp,
                    //   );
                    // });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 50),
                      fadeOutDuration: const Duration(milliseconds: 50),
                      imageUrl:
                          controller.categoriesWallpapers[index].thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: controller.categoriesWallpapers.length,
            ),
          ),
          if (controller.isLoading.value)
            SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
