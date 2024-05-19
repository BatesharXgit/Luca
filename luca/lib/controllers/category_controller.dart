import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_wallpaper.dart';

class CategoryController extends GetxController {
  final String category;
  late ScrollController scrollController;
  var isLoading = false.obs;
  var categoriesWallpapers = <CategoryWallpaper>[].obs;
  DocumentSnapshot? lastDocument;

  CategoryController(this.category);

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    _fetchInitialWallpapers();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoading.value && lastDocument != null) {
        _loadMoreWallpapers();
      }
    }
  }

  Future<void> _fetchInitialWallpapers() async {
    isLoading.value = true;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(category)
          .collection('${category}Images')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      // Counting the number of documents read
      print('Fetched ${snapshot.docs.length} documents.');

      List<CategoryWallpaper> fetchedWallpapers = snapshot.docs.map((doc) {
        return CategoryWallpaper(
          title: doc['title'],
          url: doc['url'],
          thumbnailUrl: doc['thumbnailUrl'],
          uploaderName: doc['uploaderName'],
          timestamp: (doc['timestamp'] as Timestamp).millisecondsSinceEpoch,
        );
      }).toList();

      categoriesWallpapers.value = fetchedWallpapers;
      lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    } catch (e) {
      print('Error fetching wallpapers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMoreWallpapers() async {
    if (lastDocument == null || isLoading.value) return;
    isLoading.value = true;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(category)
          .collection('${category}Images')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(20)
          .get();

      // Counting the number of documents read
      print('Fetched ${snapshot.docs.length} documents.');

      List<CategoryWallpaper> moreWallpapers = snapshot.docs.map((doc) {
        return CategoryWallpaper(
          title: doc['title'],
          url: doc['url'],
          thumbnailUrl: doc['thumbnailUrl'],
          uploaderName: doc['uploaderName'],
          timestamp: (doc['timestamp'] as Timestamp).millisecondsSinceEpoch,
        );
      }).toList();

      categoriesWallpapers.addAll(moreWallpapers);
      lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    } catch (e) {
      print('Error fetching more wallpapers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
