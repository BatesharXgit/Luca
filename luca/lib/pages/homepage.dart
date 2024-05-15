import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luca/pages/categories.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late Database _database;
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  bool _isLoading = false;

  List<Wallpaper> wallpapers = [];
  int index = 0;

  List<String> data = [
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

  @override
  void initState() {
    super.initState();
    // _initDatabase();
    scrollController.addListener(_scrollListener);

    _tabController = TabController(length: data.length, vsync: this);
    // _listenForNewWallpapers();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
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
    setState(() {
      _isLoading = true;
    });

    try {
      List<Wallpaper> fetchedWallpapers = await _getWallpapersFromSQLite();

      if (fetchedWallpapers.isEmpty) {
        // If no wallpapers found in SQLite, fetch from Firestore
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
        .limit(20)
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

  DocumentSnapshot<Object?>? _lastDocument;
  Future<void> _loadMoreWallpapers() async {
    setState(() {
      _isLoading = true;
    });

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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
      setState(() {
        wallpapers.insert(0, newWallpaper);
      });
    }
  }

  Widget _buildImageGridFromRef() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: CustomScrollView(
        controller: scrollController,
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
                        url: wallpapers[index].url,
                        uploaderName: wallpapers[index].uploaderName,
                        title: wallpapers[index].title,
                        thumbnailUrl: wallpapers[index].thumbnailUrl,
                      ),
                      transition: Transition.downToUp,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 50),
                      fadeOutDuration: const Duration(milliseconds: 50),
                      imageUrl: wallpapers[index].thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Components.buildShimmerEffect(context),
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
                child: Components.buildPlaceholder(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabViews(context) {
    return TabBarView(
      controller: _tabController,
      children: List.generate(data.length, (index) {
        if (index == 0) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: _buildImageGridFromRef(),
          );
        } else {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: CategoriesWallpaper(data[index],),
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              TabBar(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                physics: const BouncingScrollPhysics(),
                indicatorPadding: const EdgeInsets.fromLTRB(0, 42, 0, 2),
                controller: _tabController,
                indicatorColor: primaryColor,
                labelPadding: EdgeInsets.only(right: 10, left: 10),
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                labelColor: primaryColor,
                unselectedLabelColor: secondaryColor,
                isScrollable: true,
                tabs: data.map((tab) {
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
              Expanded(child: _buildTabViews(context)),
            ],
          ),
        ),
      ),
    );
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
      timestamp: map['timestamp'] as int, // Corrected parsing here
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
