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
import 'package:luca/pages/static/walls_category.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:luca/pages/searchresult.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luca/services/admob_service.dart';

class MyHomePage extends StatefulWidget {
  final ScrollController controller;
  const MyHomePage({
    required this.controller,
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

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    fetchUserProfileData();
    _fetchInitialWallpapers();
    _tabController = TabController(length: 2, vsync: this);
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

  // void _fetchWallpapers() async {
  //   try {
  //     CollectionReference wallsCollectionRef =
  //         FirebaseFirestore.instance.collection('RecentImagesHome');
  //     QuerySnapshot snapshot = await wallsCollectionRef.get();

  //     setState(() {
  //       wallpapers = snapshot.docs.map((doc) {
  //         return Wallpaper(
  //           title: doc['title'],
  //           url: doc['url'],
  //           thumbnailUrl: doc['thumbnailUrl'],
  //           uploaderName: doc['uploaderName'],
  //         );
  //       }).toList();
  //     });
  //   } catch (e) {
  //     print('Error fetching wallpapers: $e');
  //   }
  // }

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
    EdgeInsets padding = MediaQuery.of(context).padding;

    return Scaffold(
      // extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        controller: widget.controller,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              forceMaterialTransparency: true,
              expandedHeight: MediaQuery.of(context).size.height * 0.40,
              floating: false,
              pinned: false,
              backgroundColor: Theme.of(context).colorScheme.background,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: _buildAppBar(),
              ),
            ),
            SliverAppBar(
              forceMaterialTransparency: true,
              elevation: 0,
              // forceMaterialTransparency: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Theme.of(context).colorScheme.background,
                  width: double.infinity,
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Explore'),
                      Tab(text: 'Random'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: _buildTabViews(),
      ),
    );
  }

  Widget _buildAppBar() {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    EdgeInsets padding = MediaQuery.of(context).padding;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, padding.top + 10, 20, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello ${userName?.split(' ')[0]},',
                style: GoogleFonts.openSans(
                  fontSize: 24,
                  color: primaryColor,
                  letterSpacing: 0.01,
                  // fontWeight: FontWeight.w200,
                  // shadows: [
                  //   Shadow(
                  //     offset: const Offset(0, 4),
                  //     blurRadius: 8,
                  //     color: primaryColor.withOpacity(0.4),
                  //   ),
                  // ],
                ),
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
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Explore',
              style: TextStyle(
                fontSize: 44,
                color: primaryColor,
                fontFamily: 'Sansilk',
                fontWeight: FontWeight.w200,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    color: primaryColor.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
          _buildSearchWidget(),
          SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '''Editor's Choice''',
              style: GoogleFonts.openSans(
                fontSize: 18,
                color: primaryColor,
                letterSpacing: 0.01,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Expanded(
          //   child: CustomScrollView(
          //     scrollDirection: Axis.horizontal,
          //     physics: const ClampingScrollPhysics(),
          //     slivers: <Widget>[
          //       SliverGrid(
          //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //           crossAxisCount: 1,
          //           childAspectRatio: 0.65,
          //         ),
          //         delegate: SliverChildBuilderDelegate(
          //           (BuildContext context, int index) {
          //             return GestureDetector(
          //               onTap: () {
          //                 Get.to(
          //                   ApplyWallpaperPage(
          //                     url: wallpapers[index].url,
          //                     uploaderName: wallpapers[index].uploaderName,
          //                     title: wallpapers[index].title,
          //                     thumbnailUrl: wallpapers[index].thumbnailUrl,
          //                   ),
          //                   transition: Transition.downToUp,
          //                 );
          //               },
          //               child: Padding(
          //                 padding: const EdgeInsets.symmetric(
          //                   vertical: 6.0,
          //                   horizontal: 6.0,
          //                 ),
          //                 child: ClipRRect(
          //                   borderRadius: BorderRadius.circular(26),
          //                   child: LocationListItem(
          //                     imageUrl: wallpapers[index].thumbnailUrl,
          //                     scrollController: scrollController,
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //           childCount: wallpapers.length,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchWidget() {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 44,
      width: MediaQuery.of(context).size.width - 48,
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: primaryColor),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(fontSize: 14, color: primaryColor),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(14.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: primaryColor),
          ),
          prefixIcon: IconButton(
            icon: Icon(
              IconlyBold.search,
              color: primaryColor,
              size: 28,
            ),
            onPressed: () {},
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ),
        onSubmitted: (query) {
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
    );
  }

  Widget _buildImageGridFromRef() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: CustomScrollView(
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
                      child: LocationListItem(
                        imageUrl: wallpapers[index].thumbnailUrl,
                        scrollController: scrollController,
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
          if (!_isLoading && _lastDocument != null)
            SliverToBoxAdapter(
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 64, 10),
                child: InkWell(
                  onTap: _loadMoreWallpapers,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'See More',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.background,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              )),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGridFromRef1() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: CustomScrollView(
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
                    // _showInterstitialAd();
                    Get.to(
                        ApplyWallpaperPage(
                          url: wallpapers[index].url,
                          uploaderName: wallpapers[index].uploaderName,
                          title: wallpapers[index].title,
                          thumbnailUrl: wallpapers[index].thumbnailUrl,
                        ),
                        transition: Transition.downToUp);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: LocationListItem(
                        imageUrl: randomWallpapers[index].thumbnailUrl,
                        scrollController: scrollController,
                      ),
                    ),
                  ),
                );
              },
              childCount: randomWallpapers.length,
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
          child: _buildImageGridFromRef1(),
        ),
      ],
    );
  }
}
