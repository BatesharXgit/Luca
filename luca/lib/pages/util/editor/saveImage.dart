import 'dart:io';
import 'dart:typed_data';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class ApplyWalls extends StatefulWidget {
  final Uint8List? editedImageBytes;

  ApplyWalls({required this.editedImageBytes});

  @override
  State<ApplyWalls> createState() => _ApplyWallsState();
}

class _ApplyWallsState extends State<ApplyWalls> {
  @override
  Widget build(BuildContext context) {
    if (widget.editedImageBytes == null) {
      // Handle the case where editedImageBytes is null
      return Scaffold(
        body: Center(
          child: Text('No edited image data available'),
        ),
      );
    } else {
      return Scaffold(
        body: Image.memory(
          widget.editedImageBytes!,
          fit: BoxFit.cover,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _applyWallpaper();
          },
          child: Icon(Icons.wallpaper),
        ),
      );
    }
  }

  Future<void> _applyWallpaper() async {
    // Get the directory where the edited image will be saved
    final Directory directory = await getApplicationDocumentsDirectory();
    final String imagePath = '${directory.path}/edited_wallpaper.jpg';

    // Write the image data to a file
    File(imagePath).writeAsBytesSync(widget.editedImageBytes!);

    bool wallpaperSet = await AsyncWallpaper.setWallpaperFromFile(
      filePath: imagePath,
      wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
      goToHome: false,
      toastDetails: ToastDetails(
        message: "Wallpaper applied successfully!",
        backgroundColor: Colors.green,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      ),
      errorToastDetails: ToastDetails(
        message: "Failed to set wallpaper.",
        backgroundColor: Colors.red,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      ),
    );

    if (wallpaperSet) {
      print('Wallpaper applied successfully.');
      await File(imagePath).delete();
      print('Image file deleted.');
    } else {
      print('Failed to set wallpaper.');
    }
  }
}
