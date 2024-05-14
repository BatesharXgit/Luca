import 'package:cloud_firestore/cloud_firestore.dart';


class Wallpaper {
  String title;
  String url;
  String thumbnailUrl;
  String uploaderName;
  Timestamp? timestamp;

  Wallpaper({
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.uploaderName,
    this.timestamp,
  });
}