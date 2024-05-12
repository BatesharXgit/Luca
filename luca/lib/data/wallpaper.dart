// import 'package:cloud_firestore/cloud_firestore.dart';

// class Wallpaper {
//   String title;
//   String url;
//   String thumbnailUrl;
//   String uploaderName;
//   Timestamp? timestamp;

//   Wallpaper({
//     required this.title,
//     required this.url,
//     required this.thumbnailUrl,
//     required this.uploaderName,
//     this.timestamp,
//   });

//   // Deserializing from JSON
//   factory Wallpaper.fromJson(Map<String, dynamic> json) {
//     return Wallpaper(
//       title: json['title'],
//       url: json['url'],
//       thumbnailUrl: json['thumbnailUrl'],
//       uploaderName: json['uploaderName'],
//       timestamp: json['timestamp'] != null
//           ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'])
//           : null,
//     );
//   }

//   // Serializing to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'url': url,
//       'thumbnailUrl': thumbnailUrl,
//       'uploaderName': uploaderName,
//       'timestamp': timestamp?.millisecondsSinceEpoch,
//     };
//   }
// }

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

  // Deserialize from JSON
  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      uploaderName: json['uploaderName'],
      timestamp: json['timestamp'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'uploaderName': uploaderName,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toSharedPreferencesJson() {
    return {
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'uploaderName': uploaderName,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }

  // Deserialize from SharedPreferences JSON
  factory Wallpaper.fromSharedPreferencesJson(Map<String, dynamic> json) {
    return Wallpaper(
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      uploaderName: json['uploaderName'],
      timestamp: json['timestamp'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
    );
  }
}
