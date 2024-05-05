import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<String> data = ['Recent', 'Illustration', 'AI', 'Cars', 'Nature'];

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    fetchUserProfileData();
    _fetchInitialWallpapers();
    scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 5, vsync: this);
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: TabBar(
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        physics: const BouncingScrollPhysics(),
        indicatorPadding: const EdgeInsets.fromLTRB(0, 42, 0, 2),
        controller: _tabController,
        indicatorColor: primaryColor,
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
              style: GoogleFonts.kanit(
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
      body: _buildTabViews(),
    );
  }

  Widget _buildSearchWidget() {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    Color tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Visibility(
          visible: !isSearchVisible,
          child: IconButton(
            icon: Icon(
              IconlyLight.search,
              color: secondaryColor,
              size: 26,
            ),
            onPressed: () {
              setState(() {
                isSearchVisible = true;
              });
            },
          ),
        ),
        AnimatedContainer(
          transformAlignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 400),
          width: isSearchVisible ? 140.0 : 0.0,
          height: 42,
          alignment: isSearchVisible ? Alignment.center : Alignment.centerRight,
          child: isSearchVisible
              ? SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: secondaryColor),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(fontSize: 14, color: secondaryColor),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.all(14.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: secondaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: secondaryColor),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            isSearchVisible = false;
                            _searchController.clear();
                          });
                        },
                      ),
                    ),
                    onSubmitted: (query) {
                      setState(() {
                        isSearchVisible = false;
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchWallpaper(
                            title: "Search Wallpaper",
                            query: query,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : null,
        ),
        const SizedBox(
          width: 8,
        ),
        GestureDetector(
          onTap: () => Get.to(() => const SettingsPage(),
              transition: Transition.rightToLeftWithFade),
          child: (userPhotoUrl != null)
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                    userPhotoUrl!,
                  ),
                )
              : Icon(
                  Icons.person,
                  color: primaryColor,
                  size: 28,
                ),
        ),
      ],
    );
  }

  Widget _buildImageGridFromRef() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: CustomScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 6.0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      // child: LocationListItem(
                      //   imageUrl: wallpapers[index].thumbnailUrl,
                      //   scrollController: scrollController,
                      // ),
                      child: CachedNetworkImage(
                        fadeInDuration: const Duration(milliseconds: 50),
                        fadeOutDuration: const Duration(milliseconds: 50),
                        imageUrl: wallpapers[index].thumbnailUrl,
                        // key: _backgroundImageKey,
                        fit: BoxFit.cover,
                        // cacheManager: DefaultCacheManager(),
                        placeholder: (context, url) =>
                            Components.buildShimmerEffect(context),
                      ),
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
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: _buildImageGridFromRef(),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Text(
              'Illustration',
              style: TextStyle(
                fontSize: 44,
                color: Colors.white,
                fontFamily: 'Sansilk',
                fontWeight: FontWeight.w200,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Text(
              'AI',
              style: TextStyle(
                fontSize: 44,
                color: Colors.white,
                fontFamily: 'Sansilk',
                fontWeight: FontWeight.w200,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Text(
              'Cars',
              style: TextStyle(
                fontSize: 44,
                color: Colors.white,
                fontFamily: 'Sansilk',
                fontWeight: FontWeight.w200,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Text(
              'Nature',
              style: TextStyle(
                fontSize: 44,
                color: Colors.white,
                fontFamily: 'Sansilk',
                fontWeight: FontWeight.w200,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
