import 'dart:io';
import 'dart:math';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luca/services/admob_service.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

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

class _ApplyWallpaperPageState extends State<ApplyWallpaperPage> {
  late ConfettiController _controllerCenter;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _globalKey = GlobalKey();
  bool _isImageLiked = false;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
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

  InterstitialAd? _interstitialAd;
  void _createBannerAd() {}

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
    _scrollController.dispose();
    _controllerCenter.dispose();
    super.dispose();
  }

  void savetoGallery(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final externalDir = await getExternalStorageDirectory();
        final filePath = '${externalDir!.path}/LucaImage.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        final result = await ImageGallerySaver.saveFile(filePath);

        if (result['isSuccess']) {
          if (kDebugMode) {
            print('Screenshot saved to gallery.');
          }

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF131321),
              content: Text(
                'Successfully saved to gallery 😊',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        } else {
          if (kDebugMode) {
            print('Failed to save screenshot to gallery.');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
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

  void toggleWidgetsVisibility() {
    setState(() {
      isWidgetsVisible = !isWidgetsVisible;
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
      String uploader, String title) {
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
        }).catchError((error) {
          print('Failed to like image: $error');
        });
      }
    }).catchError((error) {
      print('Error checking if image is already liked: $error');
    });
  }

//   void checkUserId() {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     User? user = auth.currentUser;

//   if (user != null) {
//     String userId = user.uid;
//     print('User is authenticated. User ID: $userId');
//   } else {
//     print('User is not authenticated.');
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: AnimationLimiter(
        child: Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: toggleWidgetsVisibility,
                // onVerticalDragEnd: (DragEndDetails details) {
                //   if (details.primaryVelocity! > 0) {
                //     FirebaseAuth auth = FirebaseAuth.instance;
                //     User? user = auth.currentUser;
                //     checkIfImageIsLiked(
                //         user!.uid, _wallpapers[_currentIndex].url);
                //     setState(() {
                //       _currentIndex--;
                //     });
                //   } else if (details.primaryVelocity! < 0) {
                //     FirebaseAuth auth = FirebaseAuth.instance;
                //     User? user = auth.currentUser;
                //     checkIfImageIsLiked(
                //         user!.uid, _wallpapers[_currentIndex].url);
                //     setState(() {
                //       _currentIndex++;
                //     });
                //   }
                // },
                child: Hero(
                  tag: widget.url,
                  child: RepaintBoundary(
                    key: _globalKey,
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
                          return Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        widget.thumbnailUrl))),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                                value: downloadProgress.progress,
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
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 10,
                      right: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Iconsax.close_circle,
                          color: Theme.of(context).iconTheme.color,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: isWidgetsVisible,
                child: Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isWidgetsVisible ? 1.0 : 0.0,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: () {
                                FirebaseAuth auth = FirebaseAuth.instance;
                                User? user = auth.currentUser;
                                if (user != null) {
                                  String userId = user.uid;
                                  String imageUrl = widget.url;
                                  String thumbnailUrl = widget.thumbnailUrl;
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
                              },
                              icon: Icon(
                                // Conditionally display filled or outline icon based on whether the image is liked
                                _isImageLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isImageLiked ? Colors.red : null,
                              ),
                            )),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isWidgetsVisible ? 1.0 : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              shape: BoxShape.circle),
                          child: IconButton(
                            onPressed: () {
                              _showInterstitialAd();
                              savetoGallery(context);
                            },
                            icon: Icon(
                              IconlyBold.download,
                              color: Theme.of(context).iconTheme.color,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isWidgetsVisible ? 1.0 : 0.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: () {
                                _showInterstitialAd();
                                openDialog();
                              },
                              icon: Icon(
                                Icons.format_paint,
                                color: Theme.of(context).iconTheme.color,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
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
}
