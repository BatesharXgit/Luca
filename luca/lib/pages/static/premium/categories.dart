import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

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
  late Database _database;
  bool _isLoading = false;
  List<CategoryWallpaper> wallpapers = [];
  DocumentSnapshot<Object?>? _lastDocument;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
    // _initDatabaseAndFetchWallpapers();
    // _listenForNewWallpapers();
  }

  Future<void> _initDatabaseAndFetchWallpapers() async {
    await _initDatabase();
    await fetchInitialWallpapers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      path.join(await getDatabasesPath(), 'category_wallpapers.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE category_wallpapers(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, url TEXT, thumbnailUrl TEXT, uploaderName TEXT, timestamp INTEGER, category TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> fetchInitialWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<CategoryWallpaper> fetchedWallpapers =
          await _getWallpapersFromSQLite();

      if (fetchedWallpapers.isEmpty) {
        fetchedWallpapers = await _fetchWallpapersFromFirestore();
      }

      setState(() {
        wallpapers = fetchedWallpapers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching wallpapers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<CategoryWallpaper>> _getWallpapersFromSQLite() async {
    final List<Map<String, dynamic>> wallpapersMap = await _database.query(
      'category_wallpapers',
      where: 'category = ?',
      whereArgs: [widget.category],
    );

    List<CategoryWallpaper> existingWallpapers =
        wallpapersMap.map((map) => CategoryWallpaper.fromMap(map)).toList();

    // Filter out duplicate wallpapers
    existingWallpapers.removeWhere((wallpaper) =>
        wallpapers.any((existingWallpaper) => existingWallpaper == wallpaper));

    return existingWallpapers;
  }

  Future<List<CategoryWallpaper>> _fetchWallpapersFromFirestore() async {
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

      // Filter out duplicate wallpapers
      fetchedWallpapers.removeWhere((newWallpaper) => wallpapers.any(
          (existingWallpaper) => existingWallpaper.url == newWallpaper.url));

      await _storeWallpapersInSQLite(fetchedWallpapers);

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      return fetchedWallpapers;
    } catch (e) {
      print('Error fetching wallpapers from Firestore: $e');
      return [];
    }
  }

  Future<void> _storeWallpapersInSQLite(
      List<CategoryWallpaper> wallpapers) async {
    // Clear existing data in the category_wallpapers table
    await _database.delete('category_wallpapers',
        where: 'category = ?', whereArgs: [widget.category]);

    // Insert new wallpapers into the database
    for (var wallpaper in wallpapers) {
      await _database.insert(
        'category_wallpapers',
        {
          'title': wallpaper.title,
          'url': wallpaper.url,
          'thumbnailUrl': wallpaper.thumbnailUrl,
          'uploaderName': wallpaper.uploaderName,
          'timestamp': wallpaper.timestamp,
          'category': widget.category,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _loadMoreWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot;
      if (_lastDocument != null) {
        snapshot = await FirebaseFirestore.instance
            .collection('Categories')
            .doc(widget.category)
            .collection('${widget.category}Images')
            .orderBy('timestamp', descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(20)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('Categories')
            .doc(widget.category)
            .collection('${widget.category}Images')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();
      }

      List<CategoryWallpaper> moreWallpapers = snapshot.docs.map((doc) {
        return CategoryWallpaper(
          title: doc['title'],
          url: doc['url'],
          thumbnailUrl: doc['thumbnailUrl'],
          uploaderName: doc['uploaderName'],
          timestamp: (doc['timestamp'] as Timestamp).millisecondsSinceEpoch,
        );
      }).toList();

      // Filter out duplicates
      moreWallpapers.removeWhere((wallpaper) => wallpapers
          .any((existingWallpaper) => existingWallpaper.url == wallpaper.url));

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      await _storeWallpapersInSQLite(moreWallpapers);

      setState(() {
        wallpapers.addAll(moreWallpapers);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching more wallpapers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listenForNewWallpapers() {
    FirebaseFirestore.instance
        .collection('Categories')
        .doc(widget.category)
        .collection('${widget.category}Images')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _getWallpapersFromSQLite().then((sqliteWallpapers) {
          if (sqliteWallpapers.isEmpty) {
            _fetchAndDisplayNewWallpaper();
          } else {
            CategoryWallpaper newWallpaper = CategoryWallpaper(
              title: snapshot.docs.first['title'],
              url: snapshot.docs.first['url'],
              thumbnailUrl: snapshot.docs.first['thumbnailUrl'],
              uploaderName: snapshot.docs.first['uploaderName'],
              timestamp: (snapshot.docs.first['timestamp'] as Timestamp)
                  .millisecondsSinceEpoch,
            );
            if (!sqliteWallpapers.contains(newWallpaper)) {
              _storeWallpaperInSQLite(newWallpaper);
              setState(() {
                wallpapers.insert(0, newWallpaper);
              });
            }
          }
        });
      }
    });
  }

  Future<void> _storeWallpaperInSQLite(CategoryWallpaper wallpaper) async {
    await _database.insert(
      'category_wallpapers',
      {
        'title': wallpaper.title,
        'url': wallpaper.url,
        'thumbnailUrl': wallpaper.thumbnailUrl,
        'uploaderName': wallpaper.uploaderName,
        'timestamp': wallpaper.timestamp,
        'category': widget.category,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  void _fetchAndDisplayNewWallpaper() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Categories')
        .doc(widget.category)
        .collection('${widget.category}Images')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    CategoryWallpaper newWallpaper = CategoryWallpaper(
      title: snapshot.docs.first['title'],
      url: snapshot.docs.first['url'],
      thumbnailUrl: snapshot.docs.first['thumbnailUrl'],
      uploaderName: snapshot.docs.first['uploaderName'],
      timestamp: (snapshot.docs.first['timestamp'] as Timestamp)
          .millisecondsSinceEpoch,
    );

    bool exists =
        wallpapers.any((wallpaper) => wallpaper.url == newWallpaper.url);

    if (!exists) {
      setState(() {
        wallpapers.insert(0, newWallpaper);
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
                  // Handle wallpaper tap
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 50),
                    fadeOutDuration: const Duration(milliseconds: 50),
                    imageUrl: wallpapers[index].thumbnailUrl,
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
            childCount: wallpapers.length,
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

  factory CategoryWallpaper.fromMap(Map<String, dynamic> map) {
    return CategoryWallpaper(
      title: map['title'],
      url: map['url'],
      thumbnailUrl: map['thumbnailUrl'],
      uploaderName: map['uploaderName'],
      timestamp: map['timestamp'] != null ? map['timestamp'] as int : 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryWallpaper &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          url == other.url &&
          thumbnailUrl == other.thumbnailUrl &&
          uploaderName == other.uploaderName &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      title.hashCode ^
      url.hashCode ^
      thumbnailUrl.hashCode ^
      uploaderName.hashCode ^
      timestamp.hashCode;
}
