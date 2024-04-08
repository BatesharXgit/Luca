import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadAndUpload extends StatelessWidget {
  DownloadAndUpload({Key? key}) : super(key: key);

  Future<void> uploadImageAndCreateDocument(String thumbnailUrl,
      String imageUrl, String title, String uploader) async {
    try {
      // Create Firestore document
      CollectionReference wallpapersRef =
          FirebaseFirestore.instance.collection('Abstract');
      await wallpapersRef.add({
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'url': imageUrl,
        'uploaderName': uploader,
      });

      print('Document created successfully for $title!');
    } catch (e) {
      print('Error creating document for $title: $e');
    }
  }

  Future<List<String>> getImageNamesFromStorage() async {
    try {
      Reference storageRef =
          FirebaseStorage.instance.ref().child('test/images');

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
    var index = Random();
    List<String> uploader = [
      'Lucid',
      'Yog',
      'Beck',
      'Ares',
      'Luca',
      'XD',
      'Rahul',
      'Peter',
      'Garry',
      'Davie'
    ];
    try {
      for (String imageName in imageNames) {
        // Download image from Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('test/images/$imageName');
        Reference thumbnailRef = FirebaseStorage.instance
            .ref()
            .child('test/images/${imageName}_400x800');

        // Upload image data along with metadata to Firestore
        final imageUrl = await storageRef.getDownloadURL();
        final thumbnailUrl = await thumbnailRef.getDownloadURL();

        String title = imageName.split('.').first;

        // Upload image data to Firestore
        await uploadImageAndCreateDocument(
          thumbnailUrl,
          imageUrl,
          title,
          uploader[(index.nextInt(uploader.length))],
        );

        print('Image $imageName downloaded and uploaded successfully!');
        print('Image URL: $imageUrl');
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
