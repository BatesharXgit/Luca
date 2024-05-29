import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luca/pages/util/apply_walls.dart';

class CategoriesWallpaper extends StatefulWidget {
  final String category;

  const CategoriesWallpaper(this.category, {super.key});

  @override
  CategoriesWallpaperState createState() => CategoriesWallpaperState();
}

class CategoriesWallpaperState extends State<CategoriesWallpaper> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  List<CategoryWallpaper> categoriesWallpapers = [];
  DocumentSnapshot? _lastDocument;

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
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _lastDocument != null) {
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
          .collection('Categories')
          .doc(widget.category)
          .collection('${widget.category}Images')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

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
        categoriesWallpapers = fetchedWallpapers;
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching wallpapers: $e');
      }
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
          .collection('Categories')
          .doc(widget.category)
          .collection('${widget.category}Images')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(20)
          .get();

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
        categoriesWallpapers.addAll(moreWallpapers);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching more wallpapers: $e');
      }
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
                    placeholder: (context, url) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              );
            },
            childCount: categoriesWallpapers.length,
          ),
        ),
        if (_isLoading)
          const SliverToBoxAdapter(
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
