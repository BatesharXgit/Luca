// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:luca/services/admob_service.dart';

// import '../main.dart';

// class HomeController extends GetxController {
//   bool isSearchVisible = false;
//   final TextEditingController searchController = TextEditingController();

//   @override
//   void onInit() {
//     super.onInit();
//     _createInterstitialAd();
//     fetchUserProfileData();
//   }

//   InterstitialAd? _interstitialAd;

//   void _createInterstitialAd() {
//     InterstitialAd.load(
//       adUnitId: AdMobService.wallOpeninterstitialAdUnitId!,
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (ad) => _interstitialAd = ad,
//         onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
//       ),
//     );
//   }

//   void showInterstitialAd() {
//     if (_interstitialAd != null) {
//       _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//         onAdDismissedFullScreenContent: (ad) {
//           ad.dispose();
//           Future.delayed(const Duration(minutes: 1), () {
//             _createInterstitialAd();
//           });
//         },
//         onAdFailedToShowFullScreenContent: (ad, error) {
//           ad.dispose();
//           Future.delayed(const Duration(minutes: 1), () {
//             _createInterstitialAd();
//           });
//         },
//       );
//       _interstitialAd!.show();
//       _interstitialAd = null;
//     }
//   }

//   String? userPhotoUrl;
//   Future<void> fetchUserProfileData() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       userPhotoUrl = user.photoURL;
//       update();
//     }
//   }

//   final Reference wallpaperRef = storage.ref().child('wallpaper');
//   List<Reference> wallpaperRefs = [];

//   Future<void> loadImages() async {
//     final ListResult wallpaperResult = await wallpaperRef.listAll();
//     wallpaperRefs = wallpaperResult.items.toList();
//   }

//   void search() {
//     isSearchVisible = true;
//     update();
//   }

//   void clearSearch() {
//     isSearchVisible = false;
//     searchController.clear();
//     update();
//   }
// }
