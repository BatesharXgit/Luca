import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luca/controllers/category_controller.dart';
import 'package:luca/controllers/home_controller.dart';
import 'package:luca/pages/util/apply_walls.dart';

import '../models/category_wallpaper.dart';

class MyHomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'LuCa',
          style: GoogleFonts.lobsterTwo(
            textStyle: TextStyle(color: primaryColor),
          ),
        ),
        bottom: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          tabs: List<Widget>.generate(
            controller.data.length,
            (int index) {
              return Tab(
                child: Text(
                  controller.data[index],
                  style: GoogleFonts.breeSerif(
                    textStyle: TextStyle(color: primaryColor),
                  ),
                ),
              );
            },
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 5,
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: List<Widget>.generate(controller.data.length, (index) {
          if (index == 0) {
            return Obx(() {
              if (controller.isLoading.value && controller.wallpapers.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }
              return GridView.builder(
                controller: controller.scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemCount: controller.wallpapers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ApplyWallpaperPage(wallpaper: controller.wallpapers[index]),
                      //   ),
                      // );
                    },
                    child: CachedNetworkImage(
                      imageUrl: controller.wallpapers[index].thumbnailUrl,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            });
          } else {
            return CategoryPage(category: controller.data[index]);
          }
        }),
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String category;
  CategoryPage({required this.category});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller =
        Get.put(CategoryController(category), tag: category);

    return Obx(() {
      if (controller.isLoading.value &&
          controller.categoriesWallpapers.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return GridView.builder(
        controller: controller.scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: controller.categoriesWallpapers.length,
        itemBuilder: (context, index) {
          CategoryWallpaper wallpaper = controller.categoriesWallpapers[index];
          return GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ApplyWallpaperPage(wallpaper: wallpaper),
              //   ),
              // );
            },
            child: CachedNetworkImage(
              imageUrl: wallpaper.thumbnailUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          );
        },
      );
    });
  }
}
