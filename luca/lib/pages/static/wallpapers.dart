import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/services/admob_service.dart';

import 'walls_category.dart';

class Category extends StatefulWidget {
  const Category({
    Key? key,
  }) : super(key: key);

  @override
  State<Category> createState() => CategoryState();
}

class CategoryState extends State<Category> {
  final List<String> _amoled = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F93.jpg?alt=media&token=dd4741da-9f8c-4c03-80b6-b2df77e5de74',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F83.jpg?alt=media&token=52cb7707-0ab0-4961-b3ad-8c79ff5c3b70',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F79.jpg?alt=media&token=ffd1a801-53c8-4df9-8269-d4a0cd394a19',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F76.jpg?alt=media&token=0f0b1b82-879b-421e-9382-e6fb5f1074ee',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F71.jpg?alt=media&token=98ede1b5-f454-43c5-a8d3-75431eb133a9',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F66.jpg?alt=media&token=3025b56b-c208-4844-8d37-c18df18b0843',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F59.jpg?alt=media&token=6db4ae15-1ea3-47c3-aa6e-b5db13ac759d',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F90.jpg?alt=media&token=5bac6a75-a3f0-4ce4-8f69-0b127c650d46'
  ];

  final List<String> _space = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F89.jpg?alt=media&token=c875c03b-bdfa-4aef-b8b3-f4db12282132',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F87.jpg?alt=media&token=781d3e0f-e785-4ff7-818d-bc0f515968c8',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F91.jpg?alt=media&token=f81a01d6-7cd7-432e-b96b-8fce1ba7582e',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F63.jpg?alt=media&token=22269ca5-b699-48b1-80f6-3030f8f02abc',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F69.jpg?alt=media&token=65b35575-8529-4bb4-89ee-e788b89573cd',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F58.jpg?alt=media&token=a2888011-e06d-40f2-97dd-b53c10afcd2f',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F77.jpg?alt=media&token=fe42823e-f2b6-4733-b9d6-2d9caf7a0008',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F68.jpg?alt=media&token=1cff5422-cdf1-4e0c-998a-f67484fbaa5d'
  ];

  final List<String> _anime = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F71.jpg?alt=media&token=2fffdff5-b525-49e3-accd-6b2c0a43919d',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F72.jpg?alt=media&token=e2b1105a-46c8-4f7c-aad0-1359f5f3fd97',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F73.jpg?alt=media&token=7a340fba-f07e-456b-ba39-2db4d87acc94',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F74.jpg?alt=media&token=4159cb05-0e30-42f6-9807-239fb20be369',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F75.jpg?alt=media&token=242ebb49-eb3b-4106-be03-df472e764494',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F76.jpg?alt=media&token=76c255cc-d440-4490-a6d8-74c8083deda8',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F77.jpg?alt=media&token=b65ae120-12d0-4cdd-a614-8d979052814c',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F78.jpg?alt=media&token=7e5d9d93-d290-419e-b458-4682f23b848d'
  ];

  final List<String> _minimalist = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F52.png?alt=media&token=9935c772-8975-480b-8605-e578bee29459',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F59.jpg?alt=media&token=f9d82472-7e9e-4b49-ab8c-c3054b283e7e',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F81.jpg?alt=media&token=e3c08b97-0be5-4ed8-b9c1-8357212b5526',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F96.jpg?alt=media&token=e021f3f1-6c0b-45fe-8e7b-3f650e15de16',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F87.jpg?alt=media&token=a0bcde27-6c86-412d-9726-41f18c40ba81',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F85.jpg?alt=media&token=f60349ef-5582-4d6f-a975-0a19e6c06c43',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F83.jpg?alt=media&token=7d13a965-64e8-421a-9c90-858744c21d1c',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F93.jpg?alt=media&token=24dd6946-4785-4ac1-92cc-d10b089b3e9c'
  ];

  final List<String> _nature = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F56.jpg?alt=media&token=90efadf0-29c9-4c59-9f49-8a135ac2f82d',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F57.jpg?alt=media&token=41282535-1cac-4b7a-9ba6-b9d1ed4f8df9',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F58.jpg?alt=media&token=e3f7fafb-32bd-43b8-b006-118f91d77048',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F62.jpg?alt=media&token=776c544d-453f-4f09-9783-e29597ad376b',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F63.jpg?alt=media&token=f1ccb12a-d7f3-4aae-9315-a6b93a55943d',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F93.jpg?alt=media&token=48d9f5e9-88b5-459b-aa78-c751d69cd541',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F68.jpg?alt=media&token=c9b7e182-0c08-4af1-9e9f-4e9527c2da3d',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F90.jpg?alt=media&token=28a131a6-314d-4ed0-9675-012dcd4b7649'
  ];

  final List<String> _animals = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F67.jpg?alt=media&token=cffe8e0c-0b86-4fae-ae9d-61c5158e042c',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F68.jpg?alt=media&token=8054027c-4f6e-4320-a4b7-3f407a53eccb',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F69.jpg?alt=media&token=9bd70d8d-fced-4ca3-8f53-b1c80534c7da',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F70.png?alt=media&token=cd524a68-c8ae-4fe1-8560-da91a131ee7b',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F71.jpg?alt=media&token=8370b1fc-6afa-4fab-9689-7a696d860536',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F72.png?alt=media&token=100c73e6-5641-475d-a517-e1a3c3239b29',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F83.jpg?alt=media&token=b639cd42-92c5-45be-abe0-afd5c15a92f5',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F78.jpg?alt=media&token=907aad23-5d05-4ed7-be65-51bf056294c8'
  ];

  final List<String> _scifi = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F100.jpg?alt=media&token=9e287ebb-d175-46dd-baec-82de147d729f',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F81.jpg?alt=media&token=aef50f00-90d6-4ea9-96e3-cde9a6c966fa',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F82.jpg?alt=media&token=439d7dc3-1e1b-4d3d-989b-407fa40a1fe3',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F83.jpg?alt=media&token=d42f4d86-ce69-4f12-a799-8cd4b7306c18',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F85.jpg?alt=media&token=5dc04103-19d4-4ee1-922a-5c1d8996d04d',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F87.jpg?alt=media&token=a6fbcc31-4b06-418b-b8ac-31df9bc46ce8',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F88.jpg?alt=media&token=e2053fcd-f3ad-4a34-9626-4d58807f2833',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F89.jpg?alt=media&token=a820d22b-b1db-4f3d-a8b3-88634a63f873'
  ];

  final List<String> _games = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F70.jpg?alt=media&token=b1b86a38-ecf3-4170-bc75-d8ec1dab3bf6',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F47.jpg?alt=media&token=c93db61e-c0b4-42e4-ba1f-d4799aa541b5',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F100.jpg?alt=media&token=b5709db6-31ba-460b-a7f2-6d0e103b425f',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F44.jpg?alt=media&token=dc3ee1bb-3a69-4ce9-b8c6-ce25aa76b89e',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F49.jpg?alt=media&token=770de000-5a97-4473-95fb-9dcb79d04e59',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F58.jpg?alt=media&token=78f5d43f-7ff5-4762-bdb2-744048aa0d11',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F73.jpg?alt=media&token=d56dce5d-91c7-49b0-b9ff-71bd2932b546',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F91.jpg?alt=media&token=cd0b5b71-5a69-4915-b6bc-52397b20a927'
  ];

  late bool _isNatureLoaded = false;
  late bool _isSpaceLoaded = false;
  late bool _isMinimalLoaded = false;
  late bool _isAnimeLoaded = false;
  late bool _isAnimalsLoaded = false;
  late bool _isSciFiLoaded = false;
  late bool _isGamesLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isNatureLoaded = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        _isSpaceLoaded = true;
        _isMinimalLoaded = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _isAnimeLoaded = true;
        _isAnimalsLoaded = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _isSciFiLoaded = true;
        _isGamesLoaded = true;
      });
    });
    _createInterstitialAd();
  }

  InterstitialAd? _interstitialAd;
  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    // Color secondaryColor = Theme.of(context).colorScheme.secondary;
    // Color tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Scaffold(
      appBar: AppBar(
        // elevation: 0,
        // centerTitle: true,

        backgroundColor: backgroundColor,
        title: Text(
          'Categories',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimationLimiter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amoled",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const AmoledWallpaper());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: 8,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApplyWallpaperPage(
                                        imageUrl: _amoled[index]),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CachedNetworkImage(
                                    fadeInDuration:
                                        const Duration(milliseconds: 200),
                                    imageUrl: _amoled[index],
                                    placeholder: (context, url) =>
                                        Components.buildShimmerEffect(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nature",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const NatureWallpaper());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 200,
                      child: (_isNatureLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _nature[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _nature[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Space",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const SpaceWallpaper());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 200,
                      child: (_isSpaceLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 120,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ApplyWallpaperPage(
                                                    imageUrl: _space[index]),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _space[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Minimalist",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const MinimalistWallpaper());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 200,
                      child: (_isMinimalLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 120,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ApplyWallpaperPage(
                                                    imageUrl:
                                                        _minimalist[index]),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _minimalist[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Anime",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const AnimeWallpapers());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 200,
                      child: (_isAnimeLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 120,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ApplyWallpaperPage(
                                                    imageUrl: _anime[index]),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          // imageUrl: _stock[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(),
                                          imageUrl: _anime[index],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Animals",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const AnimalsWallpaper());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 200,
                      child: (_isAnimalsLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _animals[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _animals[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sci-Fi",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const ScifiWallpaper());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 200,
                      child: (_isSciFiLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _scifi[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _scifi[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Games",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const GamesWallpaper());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 200,
                      child: (_isGamesLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _games[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _games[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Text(
                    "More Categories will be added soon...",
                    style: TextStyle(color: primaryColor),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
