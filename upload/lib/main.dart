import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _uploaderController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage(File image) async {
    try {
      String fileName = path.basename(image.path);
      String folderName = "Homepage_test";

      // Upload original image
      Reference storageReference =
          FirebaseStorage.instance.ref().child('$folderName/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the URL of the uploaded image
      String url = await taskSnapshot.ref.getDownloadURL();

      // Construct thumbnail name based on your naming convention
      String thumbnailFileName =
          '${path.basenameWithoutExtension(image.path)}_400x800.jpg';
      Reference thumbnailRef = FirebaseStorage.instance
          .ref()
          .child('$folderName/$thumbnailFileName');

      // Retry mechanism to get the URL of the generated thumbnail
      String? thumbnailUrl;
      int retryCount = 0;
      const int maxRetries = 5;
      const Duration retryDelay = Duration(seconds: 2);

      while (thumbnailUrl == null && retryCount < maxRetries) {
        try {
          thumbnailUrl = await thumbnailRef.getDownloadURL();
        } catch (e) {
          if (e is FirebaseException && e.code == 'object-not-found') {
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(retryDelay);
            } else {
              print('Thumbnail not found after $maxRetries attempts.');
              thumbnailUrl = 'Thumbnail not found';
            }
          } else {
            rethrow;
          }
        }
      }

      // Store metadata in Firestore
      await FirebaseFirestore.instance.collection('Explore_test').add({
        'thumbnailUrl': thumbnailUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'title': _titleController.text,
        'uploaderName': _uploaderController.text,
        'url': url,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded and metadata saved.')));
      print('Image uploaded and metadata saved.');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null ? Text('No image selected.') : Image.file(_image!),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _uploaderController,
                decoration: InputDecoration(labelText: 'Uploader Name'),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: _image == null ? null : () => _uploadImage(_image!),
                child: Text('Upload Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
