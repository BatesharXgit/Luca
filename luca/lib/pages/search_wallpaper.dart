import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import 'package:luca/controllers/ad_controller.dart';
import 'package:luca/data/search_data.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/subscription/subscription.dart';

const String API_KEY =
    'tLLFbgWVeyvt2Onc1QYv0R1BZ3IfLH7iT7zduYlsHkDyB8eSpddwR2th';

class SearchWallpaper extends StatelessWidget {
  final AdController adController = Get.put(AdController());
  final SearchWallpaperController controller =
      Get.put(SearchWallpaperController());
  final SubscriptionController subscriptionController =
      Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        controller.clearSearch();
      },
      child: Scaffold(
        appBar: null,
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  _buildSearchWidget(context),
                  Obx(() {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 50,
                      child: controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : controller.images.isEmpty
                              ? _buildSuggestions(context)
                              : _buildImageGrid(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWidget(BuildContext context) {
    Color secondaryColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.handleSearch,
          style: TextStyle(color: secondaryColor),
          decoration: InputDecoration(
            hintText: 'Search for...',
            hintStyle: TextStyle(fontSize: 14, color: secondaryColor),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(14.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: secondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: secondaryColor),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: controller.clearSearch,
            ),
            prefixIcon:
                Icon(IconlyLight.search, color: secondaryColor, size: 26),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Popular Searches',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Wrap(
            runSpacing: 8,
            spacing: 10,
            children: [
              for (var i = 0; i < colors.length; i++)
                InkWell(
                  onTap: () {
                    if (subscriptionController.isSubscribed.value) {
                      String query = popularCategories[i];
                      controller.searchImages(query);
                    } else {
                      adController.showInterstitialAd();
                      String query = popularCategories[i];
                      controller.searchImages(query);
                    }
                  },
                  child: Chip(
                    label: Text(popularCategories[i]),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Search by Colors',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Wrap(
            runSpacing: 8,
            spacing: 10,
            children: [
              for (var i = 0; i < colors.length; i++)
                InkWell(
                  onTap: () {
                    if (subscriptionController.isSubscribed.value) {
                      String query = colors[i];
                      controller.searchImages(query);
                    } else {
                      adController.showInterstitialAd();
                      String query = colors[i];
                      controller.searchImages(query);
                    }
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: chipColors[i],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return MasonryGridView.builder(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      itemCount: controller.images.length,
      itemBuilder: (context, index) {
        String mediumImageUrl = controller.images[index]['src']['medium'];
        String originalImageUrl = controller.images[index]['src']['original'];
        String author = controller.images[index]['photographer'];
        // String title = controller.images[index]['alt'];
        return GestureDetector(
          onTap: () {
            Get.to(
                ApplyWallpaperPage(
                  uploaderName: author,
                  title: '',
                  thumbnailUrl: mediumImageUrl,
                  url: originalImageUrl,
                ),
                transition: Transition.downToUp);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: originalImageUrl,
                child: CachedNetworkImage(
                  imageUrl: mediumImageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SearchWallpaperController extends GetxController {
  var images = <dynamic>[].obs;
  var isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  void searchImages(String query) async {
    isLoading.value = true;
    searchController.text = query;

    String url = 'https://api.pexels.com/v1/search?query=$query&per_page=60';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': API_KEY,
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      images.value = data['photos'];
    } else {
      images.clear();
    }
    isLoading.value = false;
  }

  void clearSearch() {
    searchController.clear();
    images.clear();
  }

  void handleSearch(String query) {
    if (query.isNotEmpty) {
      searchImages(query);
    } else {
      images.clear();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
