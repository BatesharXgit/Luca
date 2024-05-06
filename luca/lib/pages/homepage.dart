import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';
import 'package:luca/data/wallpaper.dart';
import 'package:luca/pages/settings.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:luca/pages/searchresult.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luca/services/admob_service.dart';

class MyHomePage extends StatefulWidget {
  // final ScrollController controller;
  const MyHomePage({
    // required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = false;

  // final Reference wallpaperRef = storage.ref().child('wallpaper');
  List<Reference> wallpaperRefs = [];
  List<Wallpaper> wallpapers = [];
  List<Wallpaper> randomWallpapers = [];
  String? userPhotoUrl;
  String userName = 'there';
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
    _createInterstitialAd();
    fetchUserProfileData();
    _fetchInitialWallpapers();
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

  DocumentSnapshot<Object?>? _lastDocument;

  void _fetchInitialWallpapers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Explore")
          .orderBy("timestamp", descending: true)
          .limit(20)
          .get();

      setState(() {
        wallpapers = snapshot.docs.map((doc) {
          return Wallpaper(
            title: doc['title'],
            url: doc['url'],
            thumbnailUrl: doc['thumbnailUrl'],
            uploaderName: doc['uploaderName'],
            timestamp: doc['timestamp'],
            // timestamp:
          );
        }).toList();
        _lastDocument = snapshot.docs.last;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching wallpapers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMoreWallpapers() async {
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
            .limit(16)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('Explore')
            .orderBy("timestamp", descending: true)
            .limit(16)
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

  InterstitialAd? _interstitialAd;

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.wallOpeninterstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          Future.delayed(const Duration(minutes: 1), () {
            _createInterstitialAd();
          });
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          Future.delayed(const Duration(minutes: 1), () {
            _createInterstitialAd();
          });
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  Future<void> fetchUserProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userPhotoUrl = user.photoURL;
        userName = user.displayName!;
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
    // EdgeInsets padding = MediaQuery.of(context).padding;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      body: SafeArea(
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
            Expanded(child: _buildTabViews()),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGridFromRef() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: CustomScrollView(
        controller: scrollController,
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
                child: Components.buildCircularIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: data.map((category) {
        if (category == 'All') {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: _buildImageGridFromRef(),
          );
        } else {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: _buildImageGridFromCategory(category),
          );
        }
      }).toList(),
    );
  }

  Widget _buildImageGridFromCategory(String category) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: FutureBuilder<List<Wallpaper>>(
        future: _fetchWallpapers(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No wallpapers found for this category.'));
          } else {
            return CustomScrollView(
              controller: scrollController,
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
                        onTap: () {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            fadeInDuration: const Duration(milliseconds: 50),
                            fadeOutDuration: const Duration(milliseconds: 50),
                            imageUrl: snapshot.data![index].thumbnailUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Components.buildShimmerEffect(context),
                          ),
                        ),
                      );
                    },
                    childCount: snapshot.data!.length,
                  ),
                ),
                if (_isLoading)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Components.buildCircularIndicator(),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<List<Wallpaper>> _fetchWallpapers(String category) async {
    try {
      CollectionReference categoryCollectionRef = FirebaseFirestore.instance
          .collection('Categories')
          .doc(category)
          .collection('${category}Images');

      QuerySnapshot snapshot = await categoryCollectionRef.get();

      return snapshot.docs.map((doc) {
        return Wallpaper(
          title: doc['title'],
          url: doc['url'],
          thumbnailUrl: doc['thumbnailUrl'],
          uploaderName: doc['uploaderName'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching wallpapers for category $category: $e');
      return [];
    }
  }
}
