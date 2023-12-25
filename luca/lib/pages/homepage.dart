import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:luca/pages/settings.dart';
import 'package:luca/pages/static/walls_category.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:luca/pages/searchresult.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luca/pages/util/notify/notify.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

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
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final Reference wallpaperRef = storage.ref().child('wallpaper');
  final Reference aiRef = storage.ref().child('ai');
  final Reference abstractRef = storage.ref().child('abstract');
  final Reference carsRef = storage.ref().child('cars');
  final Reference illustrationRef = storage.ref().child('illustration');
  final Reference fantasyRef = storage.ref().child('fantasy');

  List<Reference> wallpaperRefs = [];
  List<Reference> aiRefs = [];
  List<Reference> carsRefs = [];
  List<Reference> abstractRefs = [];
  List<Reference> illustrationRefs = [];
  List<Reference> fantasyRefs = [];

  String? userPhotoUrl;

  List<String> kImages = [
    'assets/slider/1.jpg',
    'assets/slider/2.jpg',
    'assets/slider/3.jpg',
    'assets/slider/4.jpg',
    'assets/slider/5.jpg',
    'assets/slider/6.jpg'
  ];

  int index = 0;

  final List<String> data = [
    "For You",
    "AI",
    "Illustration",
    "Cars",
    "Abstract",
    "Fantasy",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    // loadImages();
    _loadhomePageImages();
    fetchUserProfileData();
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

  Future<void> _loadhomePageImages() async {
    final ListResult aiResult = await aiRef.listAll();
    aiRefs = aiResult.items.toList();

    final ListResult illustrationResult = await illustrationRef.listAll();
    illustrationRefs = illustrationResult.items.toList();

    final ListResult carResult = await carsRef.listAll();
    carsRefs = carResult.items.toList();

    final ListResult abstractResult = await abstractRef.listAll();
    abstractRefs = abstractResult.items.toList();

    final ListResult fantasyResult = await fantasyRef.listAll();
    fantasyRefs = fantasyResult.items.toList();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _tabController.dispose();
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
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
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
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Prism',
                                style: TextStyle(
                                  fontFamily: "Anurati",
                                  fontSize: 28,
                                  color: primaryColor,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () => Get.to(
                                        () => const NotificationsPage(),
                                        transition:
                                            Transition.rightToLeftWithFade),
                                    icon: Icon(
                                      IconlyBold.notification,
                                      color: primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.to(const SettingsPage(),
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
                          padding: const EdgeInsets.only(left: 20, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Discover Collections',
                              style: GoogleFonts.kanit(
                                fontSize: 20,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              scrollPhysics: const BouncingScrollPhysics(),
                              height: MediaQuery.of(context).size.height * 0.24,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5),
                              enlargeCenterPage: true,
                              viewportFraction: 0.8,
                              enlargeFactor: 0.15,
                              padEnds: false,
                            ),
                            items: kImages.asMap().entries.map((entry) {
                              int index = entry.key;
                              String imageUrl = entry.value;

                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (index == 0) {
                                        Get.to(const AnimalsWallpaper(),
                                            transition:
                                                Transition.rightToLeftWithFade);
                                      } else if (index == 1) {
                                        Get.to(const GamesWallpaper(),
                                            transition:
                                                Transition.rightToLeftWithFade);
                                      } else if (index == 2) {
                                        Get.to(const GamesWallpaper(),
                                            transition:
                                                Transition.rightToLeftWithFade);
                                      } else if (index == 3) {
                                        Get.to(const NatureWallpaper(),
                                            transition:
                                                Transition.rightToLeftWithFade);
                                      } else if (index == 4) {
                                        Get.to(const AnimeWallpapers(),
                                            transition:
                                                Transition.rightToLeftWithFade);
                                      } else if (index == 5) {
                                        Get.to(const AmoledWallpaper(),
                                            transition:
                                                Transition.rightToLeftWithFade);
                                      }
                                    },
                                    child: Container(
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
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverAppBar(
                forceMaterialTransparency: true,
                pinned: true,
                expandedHeight: 50.0,
                // backgroundColor: Theme.of(context).colorScheme.tertiary,

                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Row(
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
                          duration: const Duration(milliseconds: 400),
                          width: isSearchVisible ? 150.0 : 0.0,
                          alignment: isSearchVisible
                              ? Alignment.center
                              : Alignment.centerRight,
                          child: isSearchVisible
                              ? SizedBox(
                                  height: 44,
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(color: backgroundColor),
                                    decoration: InputDecoration(
                                      hintText: 'Search...',
                                      hintStyle:
                                          TextStyle(color: backgroundColor),
                                      filled: true,
                                      fillColor: primaryColor,
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: backgroundColor),
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
                        Expanded(
                          child: _buildTabBar(),
                        ),
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

  Widget _buildTabBar() {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return TabBar(
      dividerColor: Colors.transparent,
      tabAlignment: TabAlignment.start,
      physics: const BouncingScrollPhysics(),
      indicatorPadding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      controller: _tabController,
      indicatorColor: Theme.of(context).colorScheme.tertiary,
      indicator: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      labelColor: const Color.fromARGB(255, 175, 202, 0),
      unselectedLabelColor: primaryColour,
      isScrollable: true,
      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
      tabs: data.map((tab) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.046,
          width: MediaQuery.of(context).size.width * 0.25,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1.0, color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Tab(
            child: Text(
              tab,
              style: GoogleFonts.kanit(
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 0.85,
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
          onTap: () => Get.to(ApplyWallpaperPage(imageUrl: imageUrl),
              transition: Transition.downToUp),
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
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildImageGridFromRef(wallpaperRef),
          _buildImageGridFromRef(aiRef),
          _buildImageGridFromRef(illustrationRef),
          _buildImageGridFromRef(carsRef),
          _buildImageGridFromRef(abstractRef),
          _buildImageGridFromRef(fantasyRef),
        ],
      ),
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
