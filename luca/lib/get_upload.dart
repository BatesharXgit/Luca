import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadAndUpload extends StatelessWidget {
  const DownloadAndUpload({Key? key}) : super(key: key);

  Future<void> uploadImageAndCreateDocument(
      String imageUrl, String title) async {
    try {
      // Create Firestore document
      CollectionReference wallpapersRef =
          FirebaseFirestore.instance.collection('wallpapers');
      await wallpapersRef.add({
        'title': title,
        'thumbnailUrl': imageUrl,
        'url': imageUrl,
        'uploaderName': 'Yog'
      });

      print('Document created successfully for $title!');
    } catch (e) {
      print('Error creating document for $title: $e');
    }
  }

  Future<List<String>> getImageNamesFromStorage() async {
    try {
      // Get reference to the "wallpapers" folder in Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child('wallpaper');

      // List all items (files and subfolders) in the "wallpapers" folder
      ListResult result = await storageRef.listAll();

      // Extract names of image files
      List<String> imageNames = result.items.map((item) => item.name).toList();

      return imageNames;
    } catch (e) {
      print('Error retrieving image names from Firebase Storage: $e');
      return [];
    }
  }

  Future<void> downloadAndUploadImages(List<String> imageNames) async {
    try {
      // Get a temporary directory to store downloaded images
      Directory tempDir = await getTemporaryDirectory();

      for (String imageName in imageNames) {
        // Download image from Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('wallpaper/$imageName');
        final byteData = await storageRef.getData();

        // Upload image to Firestore
        final imageUrl = await storageRef.getDownloadURL();
        String title =
            imageName.split('.').first; // Extracting title from file name

        // Convert byte data to File
        final file = File('${tempDir.path}/$title.jpg');
        await file.writeAsBytes(byteData!);

        // Upload image to Firestore
        await uploadImageAndCreateDocument(imageUrl, title);

        print('Image $imageName downloaded and uploaded successfully!');
        print('Image URL: $imageUrl'); // Print the image URL
      }
    } catch (e) {
      print('Error downloading and uploading images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            List<String> imageNames = await getImageNamesFromStorage();
            await downloadAndUploadImages(imageNames);
          },
          child: Text("Download and Upload"),
        ),
      ),
    );
  }
}
