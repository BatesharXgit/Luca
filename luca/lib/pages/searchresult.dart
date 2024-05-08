import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:luca/data/search_data.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/services/admob_service.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

// ignore: constant_identifier_names
const String API_KEY =
    'tLLFbgWVeyvt2Onc1QYv0R1BZ3IfLH7iT7zduYlsHkDyB8eSpddwR2th';

class SearchWallpaper extends StatefulWidget {
  const SearchWallpaper({
    Key? key,
    // required this.title, required this.query
  }) : super(key: key);

  // final String title;
  // final String query;

  @override
  State<SearchWallpaper> createState() => SearchWallpaperState();
}

class SearchWallpaperState extends State<SearchWallpaper> {
  List<dynamic> _images = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  // final String query;

  // SearchWallpaperState(this.query);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchImages(String query) async {
    setState(() {
      _isLoading = true;
    });

    String url = 'https://api.pexels.com/v1/search?query=$query&per_page=30';

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': API_KEY,
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _images = data['photos'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    // _searchController.text = widget.query;
    // _searchImages(widget.query);
  }

  BannerAd? _banner;
  InterstitialAd? _interstitialAd;
  void _createBannerAd() {
    _banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdMobService.bannerAdUnitId!,
      listener: AdMobService.bannerListener,
      request: const AdRequest(),
    )..load();
  }

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
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: null,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              buildSearchBox(context),
              Divider(
                thickness: 2,
                color: Colors.transparent,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _images.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 20),
                                Text(
                                  'Popular Searches',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    Chip(
                                      label: Text('Popular 1'),
                                    ),
                                    Chip(
                                      label: Text('Popular 2'),
                                    ),
                                    Chip(
                                      label: Text('Popular 3'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Search by Colors',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  runSpacing: 8,
                                  spacing: 10,
                                  children: [
                                    for (var i = 0; i < colors.length; i++)
                                      InkWell(
                                        onTap: () {},
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: chipColors[i],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : MasonryGridView.builder(
                            gridDelegate:
                                const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              String mediumImageUrl =
                                  _images[index]['src']['medium'];
                              String originalImageUrl =
                                  _images[index]['src']['original'];
                              return GestureDetector(
                                onTap: () {
                                  _showInterstitialAd();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ApplyWallpaperPage(
                                        uploaderName: '',
                                        title: '',
                                        thumbnailUrl: originalImageUrl,
                                        url: originalImageUrl,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Hero(
                                      tag: originalImageUrl,
                                      child: CachedNetworkImage(
                                        imageUrl: mediumImageUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
    );
  }

  Widget buildSearchBox(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.055,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) => _debouncedSearch(query),
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    color: tertiaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What you are looking for...',
                    hintStyle: GoogleFonts.kanit(
                      color: tertiaryColor.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search_outlined,
                        color: tertiaryColor,
                      ),
                      onPressed: () => _showInterstitialAd(),
                    ),
                  ),
                  cursorColor: primaryColor,
                  cursorRadius: const Radius.circular(20),
                  cursorWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Timer? _debounceTimer;

  void _debouncedSearch(String query) {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchImages(query);
    });
  }
}
