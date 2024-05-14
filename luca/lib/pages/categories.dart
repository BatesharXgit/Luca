import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesWallpaper extends StatelessWidget {
  final String category;
  static const String _categoriesWallpaperKey = 'categories';

  CategoriesWallpaper(this.category);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryWallpaper>>(
      future: _fetchWallpapers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Components.buildPlaceholder());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No wallpapers found for this category.'));
        } else {
          return _buildImageGrid(snapshot.data!);
        }
      },
    );
  }

  Widget _buildImageGrid(List<CategoryWallpaper> categoriesWallpapers) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
                    Get.to(
                      ApplyWallpaperPage(
                        url: categoriesWallpapers[index].url,
                        uploaderName: categoriesWallpapers[index].uploaderName,
                        title: categoriesWallpapers[index].title,
                        thumbnailUrl: categoriesWallpapers[index].thumbnailUrl,
                      ),
                      transition: Transition.downToUp,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 50),
                      fadeOutDuration: const Duration(milliseconds: 50),
                      imageUrl: categoriesWallpapers[index].thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Components.buildShimmerEffect(context),
                    ),
                  ),
                );
              },
              childCount: categoriesWallpapers.length,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<CategoryWallpaper>> _fetchWallpapers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? wallpapersJson = prefs.getString(_categoriesWallpaperKey);

    if (wallpapersJson != null) {
      List<dynamic> savedWallpapersJson = json.decode(wallpapersJson);
      List<CategoryWallpaper> savedWallpapers = savedWallpapersJson
          .map((wallpaperJson) =>
              CategoryWallpaper.fromSharedPreferencesJson(wallpaperJson))
          .where((wallpaper) =>
              wallpaper.category ==
              category) // Filter wallpapers for current category
          .toList();
      return savedWallpapers;
    } else {
      // If wallpapers for the category are not found in SharedPreferences, return an empty list
      return [];
    }
  }

  void saveWallpapersToSharedPreferences(
      List<CategoryWallpaper> categoriesWallpapers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> wallpapersList = categoriesWallpapers
        .map((categoriesWallpapers) =>
            categoriesWallpapers.toSharedPreferencesJson())
        .toList();
    prefs.setString(_categoriesWallpaperKey, json.encode(wallpapersList));
  }
}

class CategoryWallpaper {
  String title;
  String url;
  String thumbnailUrl;
  String uploaderName;
  Timestamp? timestamp;
  String category; // Add category property

  CategoryWallpaper({
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.uploaderName,
    this.timestamp,
    required this.category, // Initialize category property
  });

  // Deserialize from JSON
  factory CategoryWallpaper.fromJson(Map<String, dynamic> json) {
    return CategoryWallpaper(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      uploaderName: json['uploaderName'] ?? '',
      timestamp: json['timestamp'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
      category: json['category'] != null
          ? json['category']
          : '', // Provide a default value if category is null
    );
  }

  // Serialize to JSON for SharedPreferences
  Map<String, dynamic> toSharedPreferencesJson() {
    return {
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'uploaderName': uploaderName,
      'timestamp': timestamp != null ? timestamp!.millisecondsSinceEpoch : null,
      'category': category, // Serialize category property
    };
  }

  // Deserialize from SharedPreferences JSON
  factory CategoryWallpaper.fromSharedPreferencesJson(
      Map<String, dynamic> json) {
    return CategoryWallpaper(
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      uploaderName: json['uploaderName'],
      timestamp: json['timestamp'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
      category: json['category'], // Deserialize category property
    );
  }
}
