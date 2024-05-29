import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luca/controllers/ad_controller.dart';
import 'package:luca/controllers/premium_category_controller.dart';
import 'package:luca/controllers/premium_home_controller.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/subscription/subscription.dart';

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
  final AdController adController = Get.put(AdController());
  final SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  CategoryPage({required this.category});

  @override
  Widget build(BuildContext context) {
    final PremiumCategoryController controller =
        Get.put(PremiumCategoryController(category), tag: category);

    return Obx(() {
      if (controller.isLoading.value &&
          controller.categoriesWallpapers.isEmpty) {
        return Center(child: Components.buildCircularIndicator());
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
                    if (subscriptionController.isSubscribed.value) {
                      Get.to(
                        ApplyWallpaperPage(
                          url: controller.categoriesWallpapers[index].url,
                          uploaderName: controller
                              .categoriesWallpapers[index].uploaderName,
                          title: controller.categoriesWallpapers[index].title,
                          thumbnailUrl: controller
                              .categoriesWallpapers[index].thumbnailUrl,
                        ),
                        transition: Transition.downToUp,
                      );
                    } else {
                      _showSubscriptionDialog(context,
                          onComplete: () => adController.showRewardedAd(
                                onComplete: () => Get.to(
                                  ApplyWallpaperPage(
                                    url: controller
                                        .categoriesWallpapers[index].url,
                                    uploaderName: controller
                                        .categoriesWallpapers[index]
                                        .uploaderName,
                                    title: controller
                                        .categoriesWallpapers[index].title,
                                    thumbnailUrl: controller
                                        .categoriesWallpapers[index]
                                        .thumbnailUrl,
                                  ),
                                  transition: Transition.downToUp,
                                ),
                              ));
                    }
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
                          child: Components.buildShimmerEffect(context),
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
                child: Components.buildCircularIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context,
      {required VoidCallback onComplete}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Access Required',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Text(
          'You need to subscribe or watch an ad to access this feature.',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 12.0),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              adController.showRewardedAd(
                onComplete: onComplete,
              );
            },
            child: Text('Watch Ad'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              Get.to(() => SubscriptionPage());
            },
            child: Text('Buy Pro'),
          ),
        ],
      ),
    );
  }
}
