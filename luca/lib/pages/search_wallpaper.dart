import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:luca/controllers/ad_controller.dart';
import 'package:luca/data/search_data.dart';
import 'package:luca/pages/util/apply_walls.dart';
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

final AdController adController = Get.put(AdController());

class SearchWallpaperState extends State<SearchWallpaper> {
  List<dynamic> _images = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchImages(String query) async {
    setState(() {
      _isLoading = true;
      _searchController.text = query;
    });

    String url = 'https://api.pexels.com/v1/search?query=$query&per_page=60';

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

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _images.clear();
    });
  }

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      _searchImages(query);
    } else {
      setState(() {
        _images.clear();
      });
    }
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: null,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                _buildSearchWidget(),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 50,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _images.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    runSpacing: 8,
                                    spacing: 10,
                                    children: [
                                      for (var i = 0; i < colors.length; i++)
                                        InkWell(
                                          onTap: () {
                                            String query = popularCategories[i];
                                            _searchImages(query);
                                          },
                                          child: Chip(
                                            label: Text(popularCategories[i]),
                                          ),
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
                                          onTap: () {
                                            String query = colors[i];
                                            _searchImages(query);
                                          },
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ApplyWallpaperPage(
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
      ),
    );
  }

  Widget _buildSearchWidget() {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    Color tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: _searchController,
          onChanged: _handleSearch,
          style: TextStyle(color: secondaryColor),
          decoration: InputDecoration(
            hintText: 'Search for...',
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
              onPressed: _clearSearch,
            ),
            prefixIcon: Icon(
              IconlyLight.search,
              color: secondaryColor,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
