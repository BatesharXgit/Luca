import 'dart:math';
import 'dart:ui';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luca/controllers/ad_controller.dart';
import 'package:luca/pages/util/editor/editor.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:luca/subscription/subscription.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class ApplyWallpaperPage extends StatefulWidget {
  final String url;
  final String title;
  final String uploaderName;
  final String thumbnailUrl;

  const ApplyWallpaperPage({
    Key? key,
    required this.uploaderName,
    required this.title,
    required this.thumbnailUrl,
    required this.url,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ApplyWallpaperPageState createState() => _ApplyWallpaperPageState();
}

final AdController adController = Get.put(AdController());
final SubscriptionController controller = Get.put(SubscriptionController());

class _ApplyWallpaperPageState extends State<ApplyWallpaperPage> {
  late ConfettiController _controllerCenter;

  final ScrollController _scrollController = ScrollController();
  bool _isImageLiked = false;
  late Future<PaletteGenerator> _paletteGeneratorFuture;

  @override
  void initState() {
    super.initState();
    _paletteGeneratorFuture = _generatePalette();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //     systemNavigationBarColor: Colors.transparent));
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      checkIfImageIsLiked(userId, widget.url);
    }
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  Future<PaletteGenerator> _generatePalette() async {
    final imageProvider = CachedNetworkImageProvider(widget.thumbnailUrl);
    return PaletteGenerator.fromImageProvider(imageProvider);
  }

  void checkIfImageIsLiked(String userId, String imageUrl) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('LikedImages')
        .where('url', isEqualTo: imageUrl)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Image is liked by the user
        setState(() {
          _isImageLiked = true;
        });
      } else {
        // Image is not liked by the user
        setState(() {
          _isImageLiked = false;
        });
      }
    }).catchError((error) {
      print('Error checking if image is already liked: $error');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controllerCenter.dispose();
    super.dispose();
  }

  Future<void> downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      await saveToGallery(bytes);
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> saveToGallery(Uint8List imageBytes) async {
    final result = await ImageGallerySaver.saveImage(imageBytes);
    if (result != null && result.isNotEmpty) {
      Fluttertoast.showToast(
        msg: "Image saved to gallery",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to save image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> applyHomescreen(BuildContext context) async {
    try {
      Fluttertoast.showToast(
        msg: 'Applying wallpaper to home screen...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      bool success = await AsyncWallpaper.setWallpaper(
        url: widget.url,
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
        goToHome: false,
      );

      if (success) {
        _controllerCenter.play();
        successScreen();
        Fluttertoast.showToast(
          msg: 'Wallpaper set Successfully 😊',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to set wallpaper',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } on PlatformException {
      Fluttertoast.showToast(
        msg: 'Failed to set wallpaper',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> applyLockscreen(BuildContext context) async {
    try {
      Fluttertoast.showToast(
        msg: 'Applying wallpaper to lock screen...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      bool success = await AsyncWallpaper.setWallpaper(
        url: widget.url,
        wallpaperLocation: AsyncWallpaper.LOCK_SCREEN,
        goToHome: false,
      );
      // ScaffoldMessenger.of(context).removeCurrentSnackBar();

      if (success) {
        successScreen();
        _controllerCenter.play();
        Fluttertoast.showToast(
          msg: 'Wallpaper set Successfully 😊',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to set wallpaper',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } on PlatformException {
      // ScaffoldMessenger.of(context).removeCurrentSnackBar();

      Fluttertoast.showToast(
        msg: 'Failed to set wallpaper',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> applyBoth(BuildContext context) async {
    try {
      Fluttertoast.showToast(
        msg: 'Applying wallpaper to both screens...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      bool success = await AsyncWallpaper.setWallpaper(
        url: widget.url,
        wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
        goToHome: false,
      );

      // ScaffoldMessenger.of(context).removeCurrentSnackBar();

      if (success) {
        _controllerCenter.play();
        successScreen();
        Fluttertoast.showToast(
          msg: 'Wallpaper set Successfully 😊',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to set wallpaper',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } on PlatformException {
      // ScaffoldMessenger.of(context).removeCurrentSnackBar();

      Fluttertoast.showToast(
        msg: 'Failed to set wallpaper',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  bool isWidgetsVisible = true;
  bool isInformationWidgetVisible = false;

  void toggleWidgetsVisibility() {
    setState(() {
      isWidgetsVisible = !isWidgetsVisible;
    });
  }

  void toggleInfoVisibility() {
    setState(() {
      isInformationWidgetVisible = !isInformationWidgetVisible;
    });
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  void successScreen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirectionality: BlastDirectionality
                .explosive, // don't specify a direction, blast randomly
            shouldLoop:
                true, // start again as soon as the animation is finished
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // manually specify the colors to be used
            createParticlePath: drawStar, // define a custom shape/path.
          ),
        );
      },
    );
  }

  void openDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isWidgetsVisible ? 1.0 : 0.0,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isWidgetsVisible ? 1.0 : 0.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => applyHomescreen(context),
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Home Screen',
                                  style: GoogleFonts.kanit(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () => applyLockscreen(context),
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Lock Screen',
                                  style: GoogleFonts.kanit(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () => applyBoth(context),
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Both Screen',
                                  style: GoogleFonts.kanit(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.kanit(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void toggleLikeImage(String userId, String imageUrl, String thumbnailUrl,
      String uploader, String title) async {
    final isLiked = !_isImageLiked;

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('LikedImages')
        .where('url', isEqualTo: imageUrl)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Image already liked, so remove it
        querySnapshot.docs.first.reference.delete().then((_) {
          print('Image removed from liked images!');
          setState(() {
            _isImageLiked = isLiked;
          });
        }).catchError((error) {
          print('Failed to remove image from liked images: $error');
        });
      } else {
        // Image not liked, so add it
        FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('LikedImages')
            .add({
          'title': title,
          'thumbnailUrl': thumbnailUrl,
          'url': imageUrl,
          'uploaderName': uploader,
        }).then((value) {
          print('Image liked and stored successfully!');
          setState(() {
            _isImageLiked = isLiked;
          });
        }).catchError((error) {
          print('Failed to like image: $error');
        });
      }
    }).catchError((error) {
      print('Error checking if image is already liked: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isWidgetsVisible
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Luca Walls',
                style: GoogleFonts.kanit(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.background,
              elevation: 0,
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Iconsax.share)),
              ],
            )
          : null,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: AnimationLimiter(
        child: Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (isInformationWidgetVisible) {
                    toggleInfoVisibility();
                  } else {
                    toggleWidgetsVisibility();
                  }
                },
                child: Hero(
                  tag: widget.url,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      height: double.infinity,
                      width: double.infinity,
                      imageUrl: widget.url,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) {
                        if (downloadProgress.progress == 1.0) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    widget.thumbnailUrl,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                  value: downloadProgress.progress,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isWidgetsVisible ? 1.0 : 0.0,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 10,
                    ),
                    child: IconButton(
                      onPressed: toggleInfoVisibility,
                      icon: Icon(
                        IconlyLight.info_circle,
                        color: Theme.of(context).iconTheme.color,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                  child: Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.bottom + 80,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: isInformationWidgetVisible ? 1.0 : 0.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: FutureBuilder<PaletteGenerator>(
                            future: _paletteGeneratorFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else {
                                final paletteGenerator = snapshot.data!;
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 68,
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 5,
                                          ),
                                          itemCount: 5,
                                          itemBuilder: (context, index) {
                                            Color? color;
                                            if (paletteGenerator
                                                .colors.isNotEmpty) {
                                              List<Color> colorList =
                                                  paletteGenerator.colors
                                                      .toList();
                                              color = colorList[
                                                  index % colorList.length];
                                            }
                                            return Container(
                                              margin: const EdgeInsets.all(2),
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: color ?? Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.grey,
                                        thickness: 2,
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Iconsax.image,
                                                  color: Colors.grey),
                                              const SizedBox(width: 5),
                                              Text(
                                                widget.title,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Iconsax.user,
                                                  color: Colors.grey),
                                              const SizedBox(width: 5),
                                              Text(
                                                widget.uploaderName,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Row(
                                        children: [
                                          Icon(Iconsax.size,
                                              color: Colors.grey),
                                          SizedBox(width: 5),
                                          Text(
                                            '1632x3264',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          )),
                    ),
                  ),
                ),
              )),
              Visibility(
                child: Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: isWidgetsVisible ? 1.0 : 0.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            height: 64,
                            color: Colors.white.withOpacity(0.15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: isWidgetsVisible ? 1.0 : 0.0,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      IconlyBold.close_square,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (controller.isSubscribed.value) {
                                      downloadImage(widget.url);
                                      Navigator.pop(context);
                                    } else {
                                      _showSubscriptionDialog(context,
                                          onComplete: () {
                                        downloadImage(widget.url);
                                        Navigator.pop(context);
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    IconlyBold.download,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      if (controller.isSubscribed.value) {
                                        Get.to(EditWallpaper(
                                            arguments: widget.url));
                                      } else {
                                        _showSubscriptionDialog(
                                          context,
                                          onComplete: () => Get.to(
                                            EditWallpaper(
                                                arguments: widget.url),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      IconlyBold.edit,
                                      color: Colors.white,
                                      size: 34,
                                    )),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: isWidgetsVisible ? 1.0 : 0.0,
                                  child: IconButton(
                                    onPressed: () {
                                      FirebaseAuth auth = FirebaseAuth.instance;
                                      User? user = auth.currentUser;
                                      if (user != null) {
                                        String userId = user.uid;
                                        String imageUrl = widget.url;
                                        String thumbnailUrl =
                                            widget.thumbnailUrl;
                                        String uploader = widget.uploaderName;
                                        String title = widget.title;

                                        // Check if the image is already liked by the user
                                        FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(userId)
                                            .collection('LikedImages')
                                            .where('url', isEqualTo: imageUrl)
                                            .get()
                                            .then((querySnapshot) {
                                          if (querySnapshot.docs.isNotEmpty) {
                                            // Image is liked, so remove it
                                            toggleLikeImage(userId, imageUrl,
                                                thumbnailUrl, uploader, title);
                                          } else {
                                            // Image is not liked, so add it
                                            toggleLikeImage(userId, imageUrl,
                                                thumbnailUrl, uploader, title);
                                          }
                                        }).catchError((error) {
                                          print(
                                              'Error checking if image is already liked: $error');
                                        });
                                      } else {
                                        print("User is not authenticated.");
                                      }
                                      adController.showInterstitialAd();
                                    },
                                    icon: Icon(
                                      _isImageLiked
                                          ? IconlyBold.heart
                                          : IconlyLight.heart,
                                      color: _isImageLiked
                                          ? Colors.red
                                          : Colors.white,
                                      size: 34,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (controller.isSubscribed.value) {
                                      openDialog();
                                    } else {
                                      adController.showInterstitialAd();
                                      openDialog();
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    minimumSize:
                                        MaterialStateProperty.all(const Size(70, 36)),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(horizontal: 16)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                    ),
                                  ),
                                  child: const Text('Apply'),
                                ),
                              ],
                            ),
                          ),
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
      // bottomNavigationBar: _banner != null
      //     ? SizedBox(
      //         height: 52,
      //         child: AdWidget(ad: _banner!),
      //       )
      //     : const SizedBox(
      //         height: 0,
      //       ),
    );
  }

  void _showSubscriptionDialog(BuildContext context,
      {required VoidCallback onComplete}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Access Required',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Text(
          'You need to subscribe or watch an ad to access this feature.',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              adController.showRewardedAd(
                onComplete: onComplete,
              );
            },
            child: const Text('Watch Ad'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              Get.to(() => SubscriptionPage());
            },
            child: const Text('Buy Pro'),
          ),
        ],
      ),
    );
  }
}
