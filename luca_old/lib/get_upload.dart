import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DownloadAndUpload extends StatelessWidget {
  const DownloadAndUpload({Key? key}) : super(key: key);

  Future<void> uploadImageAndCreateDocument(String imageUrl,
      String thumbnailUrl, String title, String selectedUploader) async {
    try {
      CollectionReference testCollectionRef =
          FirebaseFirestore.instance.collection('Categories');

      CollectionReference imagesCollectionRef =
          testCollectionRef.doc('Superhero').collection('SuperheroImages');

      // Add document to the "images" subcollection
      await imagesCollectionRef.add({
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'url': imageUrl,
        'uploaderName': selectedUploader,
      });

      print('Document created successfully for $title!');
    } catch (e) {
      print('Error creating document for $title: $e');
    }
  }

  Future<List<String>> getImageNamesFromStorage() async {
    try {
      // Get reference to the "wallpapers" folder in Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('Categories/Superhero');

      // List all items (files and subfolders) in the "wallpapers" folder
      ListResult result = await storageRef.listAll();

      // Extract names of image files
      List<String> imageNames = result.items.map((item) => item.name).toList();

      // Filter out thumbnails
      List<String> filteredImageNames =
          imageNames.where((name) => !name.contains('_400x800')).toList();

      return filteredImageNames;
    } catch (e) {
      print('Error retrieving image names from Firebase Storage: $e');
      return [];
    }
  }

  Future<void> downloadAndUploadImages(List<String> imageNames) async {
    var index = Random();
    List<String> uploaderNames = [
      "John",
      "Yog",
      "David",
      "Sarah",
      "Lucid",
      "Luca",
      "XD",
      "Ares"
    ];
    try {
      for (String imageName in imageNames) {
        // Download image from Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('Categories/Superhero/$imageName');

        // Upload image to Firestore
        final imageUrl = await storageRef.getDownloadURL();
        String title = imageName.split('.').first;

        // Construct thumbnail URL
        String thumbnailUrl = imageUrl.replaceFirst(
            RegExp(r'\.[^.]+$'), '_400x800.${imageUrl.split('.').last}');

        String selectedUploader =
            uploaderNames[index.nextInt(uploaderNames.length)];

        // Upload image to Firestore
        await uploadImageAndCreateDocument(
            imageUrl, thumbnailUrl, title, selectedUploader);

        print('Image $imageName downloaded and uploaded successfully!');
        print('Image URL: $imageUrl'); // Print the image URL
        print('Thumbnail URL: $thumbnailUrl'); // Print the thumbnail URL
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
