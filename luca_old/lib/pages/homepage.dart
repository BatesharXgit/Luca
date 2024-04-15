import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';
import 'package:luca/data/wallpaper.dart';
import 'package:luca/pages/settings.dart';
import 'package:luca/pages/static/walls_category.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:luca/pages/searchresult.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luca/services/admob_service.dart';

List<Wallpaper> wallpapers = [];

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

  final Reference wallpaperRef = storage.ref().child('wallpaper');
  List<Reference> wallpaperRefs = [];

  String? userPhotoUrl;

  int index = 0;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    fetchUserProfileData();
    _fetchWallpapers();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _fetchWallpapers() async {
    try {
      // Reference to the "test" collection
      CollectionReference testCollectionRef =
          FirebaseFirestore.instance.collection('Categories');

      // Reference to the "images" subcollection within the "test" collection
      CollectionReference imagesCollectionRef =
          testCollectionRef.doc('Superhero').collection('SuperheroImages');

      // Get documents from the "images" subcollection
      QuerySnapshot snapshot = await imagesCollectionRef.get();

      setState(() {
        wallpapers = snapshot.docs.map((doc) {
          return Wallpaper(
            title: doc['title'],
            url: doc['url'],
            thumbnailUrl: doc['thumbnailUrl'],
            uploaderName: doc['uploaderName'],
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching wallpapers: $e');
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          // controller: widget.controller,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                forceMaterialTransparency: true,
                expandedHeight: MediaQuery.of(context).size.height * 0.16,
                floating: false,
                pinned: false,
                backgroundColor: Theme.of(context).colorScheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  background: Container(
                    color: Theme.of(context)
                        .colorScheme
                        .background
                        .withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Luca',
                                style: TextStyle(
                                  fontSize: 48,
                                  color: primaryColor,
                                  fontFamily: 'Sansilk',
                                  fontWeight: FontWeight.w200,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 4),
                                      blurRadius: 8,
                                      color: primaryColor.withOpacity(0.4),
                                    ),
                                  ],
                                ),
                              ),
                              _buildSearchWidget(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      tabs: [
                        Tab(text: 'Recent'),
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
      ),
    );
  }

  Widget _buildSearchWidget() {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Visibility(
          visible: !isSearchVisible,
          child: IconButton(
            icon: isSearchVisible
                ? Icon(
                    IconlyBold.search,
                    color: primaryColor,
                    size: 28,
                  )
                : Icon(
                    IconlyLight.search,
                    color: primaryColor,
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
                  radius: 18,
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

  Widget _buildImageGridFromRef(Reference imageRef) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // _showInterstitialAd();
                    Get.to(ApplyWallpaperPage(imageUrl: wallpapers[index].url),
                        transition: Transition.downToUp);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 6.0),
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
          child: _buildImageGridFromRef(wallpaperRef),
        ),
        Center(child: Text('Content of Tab 2')),
      ],
    );
  }
}
