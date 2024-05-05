import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luca/data/wallpaper.dart';
import 'package:luca/pages/util/location_list.dart';

import 'util/apply_walls.dart';

class FavoriteImagesPage extends StatefulWidget {
  // final ScrollController controller;
  const FavoriteImagesPage({ super.key});

  @override
  State<FavoriteImagesPage> createState() => _FavoriteImagesPageState();
}

class _FavoriteImagesPageState extends State<FavoriteImagesPage> {
  ScrollController scrollController = ScrollController();
  late Stream<QuerySnapshot> _likedImagesStream;
  List<Wallpaper> wallpapers = [];

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
  }

  void _fetchWallpapers() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      _likedImagesStream = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('LikedImages')
          .snapshots();
    }

    _likedImagesStream.listen((QuerySnapshot snapshot) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              User? user = auth.currentUser;
              String userId = user!.uid;
              _showClearFavoritesConfirmationDialog(context, userId);
            },
            icon: const Icon(Iconsax.trash),
          )
        ],
        // elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        // centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          'Favourites',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: _buildImageGridFromRef(),
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

  void _showClearFavoritesConfirmationDialog(
      BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('Clear Favorites?'),
          content: const Text(
              'Are you sure you want to clear all your favorite images?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                clearAllLikedImages(userId);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void clearAllLikedImages(String userId) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('LikedImages')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
      print('All liked images deleted successfully!');
    }).catchError((error) {
      print('Failed to delete all liked images: $error');
    });
  }
}
