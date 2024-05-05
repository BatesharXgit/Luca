import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luca/data/wallpaper.dart';

class WallpaperScreen extends StatefulWidget {
  final ScrollController controller;

  const WallpaperScreen({required this.controller, super.key});

  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Wallpaper> wallpapers = [];

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
  }

  void _fetchWallpapers() async {
    try {
      // Reference to the "test" collection
      CollectionReference testCollectionRef =
          FirebaseFirestore.instance.collection('Categories');

      // Reference to the "images" subcollection within the "test" collection
      CollectionReference imagesCollectionRef =
          testCollectionRef.doc('Abstract').collection('AbstractImages');

      // Get documents from the "images" subcollection
      QuerySnapshot snapshot = await imagesCollectionRef.get();

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
    } catch (e) {
      print('Error fetching wallpapers: $e');
    }
  }

  // void _fetchWallpapers() async {
  //   QuerySnapshot snapshot = await _firestore.collection('test').get();
  //   setState(() {
  //     wallpapers = snapshot.docs.map((doc) {
  //       return Wallpaper(
  //         title: doc['title'],
  //         url: doc['url'],
  //         thumbnailUrl: doc['thumbnailUrl'],
  //         uploaderName: doc['uploaderName'],
  //       );
  //     }).toList();
  //   });
  // }

  void _fetchHomepageWallpapers() async {
    try {
      // Reference to the "HomepageWallpapers" collection
      CollectionReference homepageCollectionRef =
          FirebaseFirestore.instance.collection('HomepageWallpapers');

      // Get documents from the "HomepageWallpapers" collection
      QuerySnapshot snapshot = await homepageCollectionRef.get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          wallpapers = snapshot.docs.map((doc) {
            // Construct Wallpaper object from document data
            return Wallpaper(
              title: doc['title'],
              url: doc['url'],
              thumbnailUrl: doc['thumbnailUrl'],
              uploaderName: doc['uploaderName'],
            );
          }).toList();
        });
      } else {
        // Handle case where no wallpapers are found
        print('No wallpapers found.');
      }
    } catch (e) {
      // Handle errors
      print('Error fetching homepage wallpapers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallpapers'),
      ),
      body: ListView.builder(
        controller: widget.controller,
        itemCount: wallpapers.length,
        itemBuilder: (context, index) {
          return Container(
            width: 400,
            height: 600,
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    CachedNetworkImageProvider(wallpapers[index].thumbnailUrl),
              ),
            ),
            child: ListTile(
              title: Text(wallpapers[index].title),
              subtitle: Text(wallpapers[index].uploaderName),
            ),
          );
        },
      ),
    );
  }
}
