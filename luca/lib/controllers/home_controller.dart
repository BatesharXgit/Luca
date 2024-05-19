import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class HomeController extends GetxController with SingleGetTickerProviderMixin {
  late Database _database;
  final ScrollController scrollController = ScrollController();
  late TabController tabController;
  var isLoading = false.obs;
  var wallpapers = <Wallpaper>[].obs;
  var data = [
    'All',
    'Abstract',
    'Amoled',
    'Animals',
    'Anime',
    'Cars',
    'Games',
    'Illustration',
    'Minimalist',
    'Nature',
    'SciFi',
    'Space',
    'Superhero',
  ];
  DocumentSnapshot<Object?>? lastDocument;

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
    scrollController.addListener(_scrollListener);
    tabController = TabController(length: data.length, vsync: this);
    _listenForNewWallpapers();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoading.value) {
        _loadMoreWallpapers();
      }
    }
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'wallpapers.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE wallpapers(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, url TEXT, thumbnailUrl TEXT, uploaderName TEXT, timestamp INTEGER)',
        );
      },
      version: 1,
    );
    await fetchInitialWallpapers();
  }

  Future<void> fetchInitialWallpapers() async {
    isLoading.value = true;

    try {
      List<Wallpaper> fetchedWallpapers = await _getWallpapersFromSQLite();

      if (fetchedWallpapers.isEmpty) {
        // If no wallpapers found in SQLite, fetch from Firestore
        fetchedWallpapers = await _fetchWallpapersFromFirestore();
      }

      wallpapers.value = fetchedWallpapers;
    } catch (e) {
      print('Error fetching wallpapers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Wallpaper>> _getWallpapersFromSQLite() async {
    final List<Map<String, dynamic>> wallpapersMap =
        await _database.query('wallpapers');

    List<Wallpaper> existingWallpapers =
        wallpapersMap.map((map) => Wallpaper.fromMap(map)).toList();

    // Filter out duplicate wallpapers
    existingWallpapers.removeWhere((wallpaper) =>
        wallpapers.any((existingWallpaper) => existingWallpaper == wallpaper));

    return existingWallpapers;
  }

  Future<List<Wallpaper>> _fetchWallpapersFromFirestore() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Explore")
        .orderBy("timestamp", descending: true)
        .limit(10)
        .get();

    List<Wallpaper> fetchedWallpapers = snapshot.docs.map((doc) {
      return Wallpaper(
        title: doc['title'],
        url: doc['url'],
        thumbnailUrl: doc['thumbnailUrl'],
        uploaderName: doc['uploaderName'],
        timestamp: doc['timestamp'].millisecondsSinceEpoch,
      );
    }).toList();

    // Filter out duplicate wallpapers
    fetchedWallpapers.removeWhere((newWallpaper) => wallpapers
        .any((existingWallpaper) => existingWallpaper.url == newWallpaper.url));

    await _storeWallpapersInSQLite(fetchedWallpapers);

    return fetchedWallpapers;
  }

  Future<void> _storeWallpapersInSQLite(List<Wallpaper> wallpapers) async {
    // Clear existing data in the wallpapers table
    // await _database.delete('wallpapers');

    // Insert new wallpapers into the database
    for (var wallpaper in wallpapers) {
      await _database.insert(
        'wallpapers',
        {
          'title': wallpaper.title,
          'url': wallpaper.url,
          'thumbnailUrl': wallpaper.thumbnailUrl,
          'uploaderName': wallpaper.uploaderName,
          'timestamp': wallpaper.timestamp,
        },
      );
    }
  }

  var _lastDocument;
  var _isLoading = false.obs;

  Future<void> _loadMoreWallpapers() async {
    if (_isLoading.value) return; // Prevent multiple simultaneous requests
    _isLoading.value = true;

    try {
      QuerySnapshot snapshot;
      if (_lastDocument != null) {
        // Fetch more wallpapers after the last document in the current list
        snapshot = await FirebaseFirestore.instance
            .collection('Explore')
            .orderBy("timestamp", descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(20)
            .get();
      } else {
        // Fetch initial wallpapers if the list is empty
        snapshot = await FirebaseFirestore.instance
            .collection('Explore')
            .orderBy("timestamp", descending: true)
            .limit(20)
            .get();
      }

      List<Wallpaper> moreWallpapers = snapshot.docs
          .map((doc) => Wallpaper(
                title: doc['title'],
                url: doc['url'],
                thumbnailUrl: doc['thumbnailUrl'],
                uploaderName: doc['uploaderName'],
                timestamp: doc['timestamp'].millisecondsSinceEpoch,
              ))
          .toList();

      // Filter out duplicates
      moreWallpapers.removeWhere((wallpaper) => wallpapers
          .any((existingWallpaper) => existingWallpaper.url == wallpaper.url));

      if (snapshot.docs.isNotEmpty) {
        // Update _lastDocument only if there are more documents available
        _lastDocument = snapshot.docs.last;
      }

      await _storeWallpapersInSQLite(moreWallpapers);

      wallpapers.addAll(moreWallpapers);
      _isLoading.value = false;

      print('Loaded ${moreWallpapers.length} more wallpapers.');
      print('Last document timestamp: ${_lastDocument?.get("timestamp")}');
    } catch (e) {
      print('Error fetching more wallpapers: $e');
      _isLoading.value = false;
    }
  }

  void _listenForNewWallpapers() {
    FirebaseFirestore.instance
        .collection('Explore')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _getWallpapersFromSQLite().then((sqliteWallpapers) {
          if (sqliteWallpapers.isEmpty) {
            _fetchAndDisplayNewWallpaper();
          } else {
            Wallpaper newWallpaper = Wallpaper(
              title: snapshot.docs.first['title'],
              url: snapshot.docs.first['url'],
              thumbnailUrl: snapshot.docs.first['thumbnailUrl'],
              uploaderName: snapshot.docs.first['uploaderName'],
              timestamp:
                  snapshot.docs.first['timestamp'].millisecondsSinceEpoch,
            );
            if (!sqliteWallpapers.contains(newWallpaper)) {
              _storeWallpaperInSQLite(newWallpaper);
            }
          }
        });
      }
    });
  }

  Future<void> _storeWallpaperInSQLite(Wallpaper wallpaper) async {
    await _database.insert(
      'wallpapers',
      {
        'title': wallpaper.title,
        'url': wallpaper.url,
        'thumbnailUrl': wallpaper.thumbnailUrl,
        'uploaderName': wallpaper.uploaderName,
        'timestamp': wallpaper.timestamp,
      },
      conflictAlgorithm:
          ConflictAlgorithm.ignore, // Ignore if wallpaper already exists
    );
  }

  void _fetchAndDisplayNewWallpaper() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Explore")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    Wallpaper newWallpaper = Wallpaper(
      title: snapshot.docs.first['title'],
      url: snapshot.docs.first['url'],
      thumbnailUrl: snapshot.docs.first['thumbnailUrl'],
      uploaderName: snapshot.docs.first['uploaderName'],
      timestamp: snapshot.docs.first['timestamp'].millisecondsSinceEpoch,
    );

    // Check if the new wallpaper already exists in the list
    bool exists =
        wallpapers.any((wallpaper) => wallpaper.url == newWallpaper.url);

    // Only insert the new wallpaper if it doesn't already exist
    if (!exists) {
      wallpapers.insert(0, newWallpaper);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

class Wallpaper {
  final String title;
  final String url;
  final String thumbnailUrl;
  final String uploaderName;
  final int timestamp;

  Wallpaper({
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.uploaderName,
    required this.timestamp,
  });

  factory Wallpaper.fromMap(Map<String, dynamic> map) {
    return Wallpaper(
      title: map['title'],
      url: map['url'],
      thumbnailUrl: map['thumbnailUrl'],
      uploaderName: map['uploaderName'],
      timestamp: map['timestamp'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallpaper &&
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
