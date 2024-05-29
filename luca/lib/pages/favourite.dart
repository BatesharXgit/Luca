import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luca/data/wallpaper.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/authentication/auth%20pages/login_page.dart';
import 'util/apply_walls.dart';

class FavoriteImagesPage extends StatefulWidget {
  const FavoriteImagesPage({super.key});

  @override
  State<FavoriteImagesPage> createState() => _FavoriteImagesPageState();
}

class _FavoriteImagesPageState extends State<FavoriteImagesPage> {
  ScrollController scrollController = ScrollController();
  late Stream<QuerySnapshot>? _likedImagesStream;
  List<Wallpaper> wallpapers = [];

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
  }

  void _fetchWallpapers() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      _likedImagesStream = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('LikedImages')
          .snapshots();

      _likedImagesStream!.listen((QuerySnapshot snapshot) {
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
    } else {
      _likedImagesStream = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (user !=
              null) // Show the delete icon only if the user is logged in
            IconButton(
              onPressed: () {
                String userId = user.uid;
                _showClearFavoritesConfirmationDialog(context, userId);
              },
              icon: const Icon(Iconsax.trash),
            )
        ],
        elevation: 0,
        forceMaterialTransparency: true,
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          'Favourites',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body:
          user == null ? _buildSignInPrompt(context) : _buildImageGridFromRef(),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Please sign in to see liked images',
            style: GoogleFonts.kanit(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.to(const LoginPage(),
                  transition: Transition.rightToLeftWithFade);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGridFromRef() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 50),
                      fadeOutDuration: const Duration(milliseconds: 50),
                      imageUrl: wallpapers[index].thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Components.buildShimmerEffect(context),
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
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
      if (kDebugMode) {
        print('All liked images deleted successfully!');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Failed to delete all liked images: $error');
      }
    });
  }
}
