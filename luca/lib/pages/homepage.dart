import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luca/pages/settings.dart';
import 'package:luca/pages/static/walls_category.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:luca/pages/searchresult.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luca/services/admob_service.dart';

// class HomePage extends StatelessWidget {
//   HomePage({super.key});

//   final _controller = Get.put(HomeController());

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

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

  final Reference wallpaperRef = storage.ref().child('wallpaper');
  List<Reference> wallpaperRefs = [];

  String? userPhotoUrl;
  bool _isBoxView = false;

  List<String> kImages = [
    'assets/slider/editor.jpg',
    'assets/slider/animals.jpg',
    'assets/slider/games.jpg',
    'assets/slider/nature.jpg',
    'assets/slider/anime.jpg',
    'assets/slider/amoled.jpg'
  ];

  int index = 0;

  List<String> kNames = [
    'Editor\'s Pick',
    'Animals',
    'Games',
    'Nature',
    'Anime',
    'Amoled',
  ];

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    fetchUserProfileData();
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

  Future<void> loadImages() async {
    final ListResult wallpaperResult = await wallpaperRef.listAll();
    wallpaperRefs = wallpaperResult.items.toList();
  }

  void changeGridStyle() {
    setState(() {
      _isBoxView = !_isBoxView;
    });
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
          controller: ScrollController(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                forceMaterialTransparency: true,
                expandedHeight: MediaQuery.of(context).size.height * 0.43,
                floating: true,
                pinned: false,
                backgroundColor: Theme.of(context).colorScheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  title: null,
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
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Visibility(
                                    visible: !isSearchVisible,
                                    child: IconButton(
                                      icon: Icon(
                                        IconlyBold.search,
                                        color: primaryColor,
                                        size: 28,
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
                                    alignment: isSearchVisible
                                        ? Alignment.center
                                        : Alignment.centerRight,
                                    child: isSearchVisible
                                        ? SizedBox(
                                            height: 44,
                                            child: TextField(
                                              controller: _searchController,
                                              style: TextStyle(
                                                  color: backgroundColor),
                                              decoration: InputDecoration(
                                                hintText: 'Search...',
                                                hintStyle: TextStyle(
                                                    fontSize: 14,
                                                    color: backgroundColor),
                                                filled: true,
                                                fillColor: primaryColor,
                                                contentPadding:
                                                    const EdgeInsets.all(14.0),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  borderSide: const BorderSide(
                                                      color:
                                                          Colors.transparent),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  borderSide: BorderSide(
                                                      color: backgroundColor),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.grey,
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
                                                    builder: (context) =>
                                                        SearchWallpaper(
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
                                    onTap: () => Get.to(
                                        () => const SettingsPage(),
                                        transition:
                                            Transition.rightToLeftWithFade),
                                    child: (userPhotoUrl != null)
                                        ? CircleAvatar(
                                            radius: 18,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Discover Collections',
                              style: GoogleFonts.kanit(
                                fontSize: 24,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildCarouselSlider(),
                      ],
                    ),
                  ),
                ),
              ),
              SliverAppBar(
                forceMaterialTransparency: true,
                pinned: true,
                expandedHeight: 50.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Positioned(
                        left: -1,
                        right: -1,
                        top: -1,
                        bottom: -1,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recently Added',
                                      style: GoogleFonts.kanit(
                                        fontSize: 22,
                                        color: primaryColor,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: changeGridStyle,
                                        icon: _isBoxView
                                            ? Icon(IconlyBold.filter)
                                            : Icon(IconlyBold.filter)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildCarouselSlider() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: CarouselSlider(
        options: CarouselOptions(
          scrollPhysics: const BouncingScrollPhysics(),
          height: MediaQuery.of(context).size.height * 0.26,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 10),
          enlargeCenterPage: true,
          viewportFraction: 0.8,
          enlargeFactor: 0.2,
        ),
        items: kImages.asMap().entries.map((entry) {
          int index = entry.key;
          String imageUrl = entry.value;

          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  _showInterstitialAd();

                  if (index == 0) {
                    Get.to(
                        const WallpapersCategory(
                          category: 'editors',
                        ),
                        transition: Transition.rightToLeftWithFade);
                  } else if (index == 1) {
                    Get.to(
                        const WallpapersCategory(
                          category: 'animals',
                        ),
                        transition: Transition.rightToLeftWithFade);
                  } else if (index == 2) {
                    Get.to(
                        const WallpapersCategory(
                          category: 'games',
                        ),
                        transition: Transition.rightToLeftWithFade);
                  } else if (index == 3) {
                    Get.to(
                        const WallpapersCategory(
                          category: 'nature',
                        ),
                        transition: Transition.rightToLeftWithFade);
                  } else if (index == 4) {
                    Get.to(
                        const WallpapersCategory(
                          category: 'anime',
                        ),
                        transition: Transition.rightToLeftWithFade);
                  } else if (index == 5) {
                    Get.to(
                        const WallpapersCategory(
                          category: 'amoled',
                        ),
                        transition: Transition.rightToLeftWithFade);
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(imageUrl),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -1,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.072,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    kNames[index],
                                    style: GoogleFonts.kanit(
                                        color: Colors.white, fontSize: 26),
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageGridFromRef(Reference imageRef) {
    return FutureBuilder<ListResult>(
      future: imageRef.listAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Components.buildPlaceholder();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.items.isNotEmpty) {
          List<Reference> imageRefs = snapshot.data!.items;
          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _isBoxView ? 1 : 2,
                  childAspectRatio: _isBoxView ? 0.85 : 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final imageRef = imageRefs[index];
                    return FutureBuilder<String>(
                      future: imageRef.getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Components.buildShimmerEffect(context);
                        } else if (snapshot.hasError) {
                          return Components.buildErrorWidget();
                        } else if (snapshot.hasData) {
                          return buildImageWidget(snapshot.data!);
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                  childCount: imageRefs.length,
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No images available'));
        }
      },
    );
  }

  Widget buildImageWidget(String imageUrl) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            _showInterstitialAd();
            Get.to(ApplyWallpaperPage(imageUrl: imageUrl),
                transition: Transition.downToUp);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LocationListItem(
                imageUrl: imageUrl,
                scrollController: scrollController,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabViews() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: _buildImageGridFromRef(wallpaperRef),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tab;

  SliverAppBarDelegate(this.tab);

  @override
  double get minExtent => 40;
  @override
  double get maxExtent => 40;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return tab;
  }
}
