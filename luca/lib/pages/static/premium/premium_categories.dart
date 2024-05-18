import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luca/pages/util/apply_walls.dart';

class PremiumCategoriesWallpaper extends StatefulWidget {
  final String category;

  const PremiumCategoriesWallpaper(this.category);

  @override
  _PremiumCategoriesWallpaperState createState() =>
      _PremiumCategoriesWallpaperState();
}

class _PremiumCategoriesWallpaperState
    extends State<PremiumCategoriesWallpaper> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  List<CategoryWallpaper> premiumWallpapers = [];
  DocumentSnapshot<Object?>? _lastDocument;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchInitialWallpapers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        _loadMoreWallpapers();
      }
    }
  }

  Future<void> _fetchInitialWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Premium')
          .doc(widget.category)
          .collection('${widget.category}Images')
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

      setState(() {
        premiumWallpapers = fetchedWallpapers;
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching wallpapers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Premium')
          .doc(widget.category)
          .collection('${widget.category}Images')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
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

      setState(() {
        premiumWallpapers.addAll(moreWallpapers);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching more wallpapers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildImageGrid(),
    );
  }

  Widget _buildImageGrid() {
    return CustomScrollView(
      controller: _scrollController,
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
                  Get.to(
                    ApplyWallpaperPage(
                      url: premiumWallpapers[index].url,
                      uploaderName: premiumWallpapers[index].uploaderName,
                      title: premiumWallpapers[index].title,
                      thumbnailUrl: premiumWallpapers[index].thumbnailUrl,
                    ),
                    transition: Transition.downToUp,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 50),
                    fadeOutDuration: const Duration(milliseconds: 50),
                    imageUrl: premiumWallpapers[index].thumbnailUrl,
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
            childCount: premiumWallpapers.length,
          ),
        ),
        if (_isLoading)
          SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

class CategoryWallpaper {
  final String title;
  final String url;
  final String thumbnailUrl;
  final String uploaderName;
  final int timestamp;

  CategoryWallpaper({
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.uploaderName,
    required this.timestamp,
  });
}
