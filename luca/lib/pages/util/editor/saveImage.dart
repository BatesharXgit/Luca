import 'dart:io';
import 'dart:ui' as ui;
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class ApplyWalls extends StatefulWidget {
  final Uint8List? editedImageBytes;

  const ApplyWalls({super.key, required this.editedImageBytes});

  @override
  State<ApplyWalls> createState() => _ApplyWallsState();
}

class _ApplyWallsState extends State<ApplyWalls> {
  final GlobalKey _globalKey = GlobalKey();

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
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imagePath = '${directory.path}/edited_wallpaper.jpg';

    // Write the image data to a file
    File(imagePath).writeAsBytesSync(widget.editedImageBytes!);

    try {
      Fluttertoast.showToast(
        msg: 'Applying wallpaper to home screen...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      bool success = await AsyncWallpaper.setWallpaperFromFile(
        filePath: imagePath,
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
        goToHome: true,
      );

      if (success) {
        Fluttertoast.showToast(
          msg: 'Wallpaper set Successfully 😊',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await File(imagePath).delete();
        SystemNavigator.pop();
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
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imagePath = '${directory.path}/edited_wallpaper.jpg';
    File(imagePath).writeAsBytesSync(widget.editedImageBytes!);

    try {
      Fluttertoast.showToast(
        msg: 'Applying wallpaper to lock screen...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      bool success = await AsyncWallpaper.setWallpaperFromFile(
        filePath: imagePath,
        wallpaperLocation: AsyncWallpaper.LOCK_SCREEN,
        goToHome: true,
      );
      // ScaffoldMessenger.of(context).removeCurrentSnackBar();

      if (success) {
        Fluttertoast.showToast(
          msg: 'Wallpaper set Successfully 😊',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await File(imagePath).delete();
        SystemNavigator.pop();
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

  Future<void> applyBoth(BuildContext context) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imagePath = '${directory.path}/edited_wallpaper.jpg';
    File(imagePath).writeAsBytesSync(widget.editedImageBytes!);

    try {
      Fluttertoast.showToast(
        msg: 'Applying wallpaper to both screens...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      bool success = await AsyncWallpaper.setWallpaperFromFile(
        filePath: imagePath,
        wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
        goToHome: true,
      );

      // ScaffoldMessenger.of(context).removeCurrentSnackBar();

      if (success) {
        Fluttertoast.showToast(
          msg: 'Wallpaper set Successfully 😊',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await File(imagePath).delete();
        SystemNavigator.pop();
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

  @override
  Widget build(BuildContext context) {
    if (widget.editedImageBytes == null) {
      // Handle the case where editedImageBytes is null
      return const Scaffold(
        body: Center(
          child: Text('No edited image data available'),
        ),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onTap: toggleWidgetsVisibility,
              child: RepaintBoundary(
                key: _globalKey,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Image.memory(
                    widget.editedImageBytes!,
                    fit: BoxFit.cover,
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: isWidgetsVisible ? 1.0 : 0.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                                  savetoGallery(context);
                                },
                                icon: const Icon(
                                  IconlyBold.download,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  openDialog();
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(70, 36)),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          horizontal: 16)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
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
      );
    }
  }

  // Future<void> _applyWallpaper() async {
  //   // Get the directory where the edited image will be saved
  //   final Directory directory = await getApplicationDocumentsDirectory();
  //   final String imagePath = '${directory.path}/edited_wallpaper.jpg';

  //   // Write the image data to a file
  //   File(imagePath).writeAsBytesSync(widget.editedImageBytes!);

  //   bool wallpaperSet = await AsyncWallpaper.setWallpaperFromFile(
  //     filePath: imagePath,
  //     wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
  //     goToHome: false,
  //     toastDetails: ToastDetails(
  //       message: "Wallpaper applied successfully!",
  //       backgroundColor: Colors.green,
  //       gravity: ToastGravity.BOTTOM,
  //       toastLength: Toast.LENGTH_LONG,
  //     ),
  //     errorToastDetails: ToastDetails(
  //       message: "Failed to set wallpaper.",
  //       backgroundColor: Colors.red,
  //       gravity: ToastGravity.BOTTOM,
  //       toastLength: Toast.LENGTH_LONG,
  //     ),
  //   );

  //   if (wallpaperSet) {
  //     if (kDebugMode) {
  //       print('Wallpaper applied successfully.');
  //     }
  //     await File(imagePath).delete();
  //     SystemNavigator.pop();
  //     if (kDebugMode) {
  //       print('Image file deleted.');
  //     }
  //   } else {
  //     print('Failed to set wallpaper.');
  //   }
  // }
}
