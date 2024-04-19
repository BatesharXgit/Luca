import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteImagesPage extends StatefulWidget {
  const FavoriteImagesPage({super.key});

  @override
  State<FavoriteImagesPage> createState() => _FavoriteImagesPageState();
}

class _FavoriteImagesPageState extends State<FavoriteImagesPage> {
  late Stream<QuerySnapshot> _likedImagesStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to fetch liked images
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      _likedImagesStream = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('LikedImages')
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              User? user = auth.currentUser;
              String userId = user!.uid;
              _showClearFavoritesConfirmationDialog(context, userId);
            },
            icon: const Icon(Iconsax.trash),
          )
        ],
        // elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        // centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          'Favourites',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: _likedImagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No wallpapers found.'));
          }
          // Display the liked wallpapers
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return ListTile(
                title: Text(doc['title']),
                subtitle: Text(doc['uploaderName']),
                leading: Image.network(doc['thumbnailUrl']),
                // You can add more UI elements or functionality here
              );
            },
          );
        },
      ),
    );
  }

  void _showClearFavoritesConfirmationDialog(
      BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('Clear Favorites?'),
          content: const Text(
              'Are you sure you want to clear all your favorite images?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                clearAllLikedImages(userId);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void clearAllLikedImages(String userId) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('LikedImages')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
      print('All liked images deleted successfully!');
    }).catchError((error) {
      print('Failed to delete all liked images: $error');
    });
  }
}
