import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luca/controllers/ad_controller.dart';
import 'package:luca/controllers/category_controller.dart';
import 'package:luca/controllers/home_controller.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/subscription/subscription.dart';

class MyHomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final AdController adController = Get.put(AdController());
  final SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              TabBar(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                physics: const BouncingScrollPhysics(),
                indicatorPadding: const EdgeInsets.fromLTRB(0, 42, 0, 2),
                controller: controller.tabController,
                indicatorColor: primaryColor,
                labelPadding: const EdgeInsets.only(right: 10, left: 10),
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                labelColor: primaryColor,
                unselectedLabelColor: secondaryColor,
                isScrollable: true,
                tabs: controller.data.map((tab) {
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
                  children:
                      List<Widget>.generate(controller.data.length, (index) {
                    if (index == 0) {
                      return Obx(() {
                        if (controller.isLoading.value &&
                            controller.wallpapers.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return _buildImageGridFromRef(controller);
                      });
                    } else {
                      return CategoryPage(category: controller.data[index]);
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: adController.bannerAd != null
      //     ? Container(
      //         alignment: Alignment.center,
      //         child: AdWidget(ad: adController.bannerAd!),
      //         width: adController.bannerAd!.size.width.toDouble(),
      //         height: adController.bannerAd!.size.height.toDouble(),
      //       )
      //     : null,
    );
  }

  Widget _buildImageGridFromRef(HomeController controller) {
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
                          url: controller.wallpapers[index].url,
                          uploaderName:
                              controller.wallpapers[index].uploaderName,
                          title: controller.wallpapers[index].title,
                          thumbnailUrl:
                              controller.wallpapers[index].thumbnailUrl,
                        ),
                        transition: Transition.downToUp,
                      );
                    } else {
                      adController.showInterstitialAd();
                      Get.to(
                        ApplyWallpaperPage(
                          url: controller.wallpapers[index].url,
                          uploaderName:
                              controller.wallpapers[index].uploaderName,
                          title: controller.wallpapers[index].title,
                          thumbnailUrl:
                              controller.wallpapers[index].thumbnailUrl,
                        ),
                        transition: Transition.downToUp,
                      );
                    }
                    // adController.showRewardedAd();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 50),
                      fadeOutDuration: const Duration(milliseconds: 50),
                      imageUrl: controller.wallpapers[index].thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Components.buildShimmerEffect(context),
                    ),
                  ),
                );
              },
              childCount: controller.wallpapers.length,
            ),
          ),
          if (controller.isLoading.value)
            SliverToBoxAdapter(
              child: Center(
                child: Components.buildPlaceholder(),
              ),
            ),
        ],
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String category;
  final SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller =
        Get.put(CategoryController(category), tag: category);

    return Obx(() {
      if (controller.isLoading.value &&
          controller.categoriesWallpapers.isEmpty) {
        return Center(child: Components.buildCircularIndicator());
      }

      return _buildImageGrid(controller);
    });
  }

  Widget _buildImageGrid(CategoryController controller) {
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
                      adController.showInterstitialAd();
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
                    }
                    // adController.showRewardedAd();
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
            const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
