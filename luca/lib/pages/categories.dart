import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class CategoriesWallpaper extends StatelessWidget {
  final String category;

  CategoriesWallpaper(this.category);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryWallpaper>>(
      future: _fetchWallpapers(category),
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

  Future<List<CategoryWallpaper>> _getWallpapersFromSQLite(
      String category) async {
    Database database = await _initDatabase();
    List<Map<String, dynamic>> wallpapersMap = await database.query(
      'category_wallpapers',
      where: 'category = ?',
      whereArgs: [category],
    );

    List<CategoryWallpaper> wallpapers = wallpapersMap.map((map) {
      return CategoryWallpaper(
        title: map['title'],
        url: map['url'],
        thumbnailUrl: map['thumbnailUrl'],
        uploaderName: map['uploaderName'],
        category: map['category'],
      );
    }).toList();

    return wallpapers;
  }

  Future<List<CategoryWallpaper>> _fetchWallpapers(String category) async {
    try {
      // Firestore collection reference
      CollectionReference categoryCollectionRef = FirebaseFirestore.instance
          .collection('Categories')
          .doc(category)
          .collection('${category}Images');

      // Query Firestore for wallpapers ordered by timestamp in descending order
      QuerySnapshot snapshot = await categoryCollectionRef
          .orderBy("timestamp", descending: true)
          .get();

      List<CategoryWallpaper> wallpapers = snapshot.docs.map((doc) {
        return CategoryWallpaper(
          title: doc['title'],
          url: doc['url'],
          thumbnailUrl: doc['thumbnailUrl'],
          uploaderName: doc['uploaderName'],
          category: category,
        );
      }).toList();

      // Store wallpapers in SQLite database
      await _storeWallpapersInSQLite(wallpapers);

      return wallpapers;
    } catch (e) {
      print('Error fetching wallpapers for category $category: $e');
      return [];
    }
  }

  Future<void> _storeWallpapersInSQLite(
      List<CategoryWallpaper> wallpapers) async {
    Database database = await _initDatabase();

    // Insert wallpapers into SQLite database
    for (var wallpaper in wallpapers) {
      await database.insert(
        'category_wallpapers', // SQLite table name
        {
          'title': wallpaper.title,
          'url': wallpaper.url,
          'thumbnailUrl': wallpaper.thumbnailUrl,
          'uploaderName': wallpaper.uploaderName,
          'category': wallpaper.category,
        },
      );
    }
  }

  Future<Database> _initDatabase() async {
    String pathToDatabase =
        path.join(await getDatabasesPath(), 'category_wallpapers.db');
    return await openDatabase(
      pathToDatabase, // Database name
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE category_wallpapers(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, url TEXT, thumbnailUrl TEXT, uploaderName TEXT, category TEXT)',
        );
      },
      version: 1,
    );
  }
}

class CategoryWallpaper {
  String title;
  String url;
  String thumbnailUrl;
  String uploaderName;
  Timestamp? timestamp;
  String category;

  CategoryWallpaper({
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.uploaderName,
    this.timestamp,
    required this.category,
  });
}
