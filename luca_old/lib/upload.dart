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

class Wallpaper {
  String title;
  String url;
  String thumbnailUrl;
  String uploaderName;

  Wallpaper(
      {required this.title,
      required this.url,
      required this.thumbnailUrl,
      required this.uploaderName});
}

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
    QuerySnapshot snapshot = await _firestore.collection('wallpapers').get();
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
                    image: CachedNetworkImageProvider(
                        wallpapers[index].thumbnailUrl))),
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

class WallpaperUploaderScreen extends StatefulWidget {
  @override
  _WallpaperUploaderScreenState createState() =>
      _WallpaperUploaderScreenState();
}

class _WallpaperUploaderScreenState extends State<WallpaperUploaderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  late String _googleAuthId;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchGoogleAuthId();
  }

  void _fetchGoogleAuthId() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    setState(() {
      _googleAuthId = googleUser!.id;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      String fileName = _imageFile!.path.split('/').last;
      Reference reference = _storage.ref().child('images/$fileName');
      UploadTask uploadTask = reference.putFile(_imageFile!);
      TaskSnapshot storageTaskSnapshot =
          await uploadTask.whenComplete(() => null);
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

      // Store wallpaper metadata in Firestore
      _firestore.collection('wallpapers').add({
        'title': 'Something',
        'url': downloadUrl,
        'uploaderName': _googleAuthId,
        'thumbnailUrl': downloadUrl,
      });

      // Reset _imageFile after uploading
      setState(() {
        _imageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Wallpaper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : Text('No image selected.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WallpaperUploaderScreen(),
  ));
}
