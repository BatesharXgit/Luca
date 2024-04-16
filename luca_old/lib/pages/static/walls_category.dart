import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:luca/services/admob_service.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

ScrollController scrollController = ScrollController();

class WallpapersCategory extends StatefulWidget {
  final String category;
  const WallpapersCategory({super.key, required this.category});

  @override
  State<WallpapersCategory> createState() => _WallpapersCategoryState();
}

class _WallpapersCategoryState extends State<WallpapersCategory> {
  late Reference imageRef;
  List<Reference> imageRefs = [];
  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    imageRef = storage.ref().child('category/${widget.category}');
    loadwallpaperCategories();
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

  Future<void> loadwallpaperCategories() async {
    final ListResult result = await imageRef.listAll();
    imageRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String capitalize(String s) {
      return s[0].toUpperCase() + s.substring(1);
    }

    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          capitalize(widget.category),
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: imageRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: imageRefs.length,
                      itemBuilder: (context, index) {
                        final amoRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: amoRef.getDownloadURL(),
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
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageWidget(String imageUrl) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            _showInterstitialAd();
            Get.to(ApplyWallpaperPage(wallpapers: [],), transition: Transition.downToUp);
          },
          child: Hero(
            tag: imageUrl,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LocationListItem(
                  imageUrl: imageUrl,
                  scrollController: scrollController,
                  imageBytes: null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
