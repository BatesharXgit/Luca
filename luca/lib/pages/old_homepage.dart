import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
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
    _initDatabase();
    scrollController.addListener(_scrollListener);
    _tabController = TabController(length: data.length, vsync: this);
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
          'CREATE TABLE wallpapers(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, url TEXT, thumbnailUrl TEXT, uploaderName TEXT, timestamp TEXT)',
        );
      },
      version: 1,
    );
    fetchInitialWallpapers();
  }

  DocumentSnapshot<Object?>? _lastDocument;

  Future<void> fetchInitialWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> wallpapersMaps =
          await _database.query('wallpapers');
      List<Wallpaper> fetchedWallpapers = wallpapersMaps.map((wallpaperMap) {
        return Wallpaper(
          title: wallpaperMap['title'],
          url: wallpaperMap['url'],
          thumbnailUrl: wallpaperMap['thumbnailUrl'],
          uploaderName: wallpaperMap['uploaderName'],
          timestamp: wallpaperMap['timestamp'],
        );
      }).toList();

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

  Future<void> _loadMoreWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot;
      if (_lastDocument != null) {
        snapshot = await FirebaseFirestore.instance
            .collection('Explore')
            .orderBy("timestamp", descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(20)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('Explore')
            .orderBy("timestamp", descending: true)
            .limit(20)
            .get();
      }

      setState(() {
        wallpapers.addAll(snapshot.docs.map((doc) {
          return Wallpaper(
            title: doc['title'],
            url: doc['url'],
            thumbnailUrl: doc['thumbnailUrl'],
            uploaderName: doc['uploaderName'],
            timestamp: doc['timestamp'],
          );
        }));
        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
        }
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

  bool isSearchVisible = false;

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
            child: CategoriesWallpaper(data[index]),
          );
        }
      }),
    );
  }
}

class Wallpaper {
  final String title;
  final String url;
  final String thumbnailUrl;
  final String uploaderName;
  final String timestamp;

  Wallpaper({
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.uploaderName,
    required this.timestamp,
  });
}
