import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:luca/authentication/auth%20pages/auth_page.dart';
// import 'package:luca/download_upload.dart';
import 'package:luca/get_upload.dart';
import 'package:luca/pages/homepage.dart';
import 'package:luca/pages/util/favourites_manager.dart';
import 'package:luca/pages/util/notify/notification.dart';
import 'package:luca/pages/util/notify/notify.dart';
import 'package:luca/themes/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<MyHomePageState> homePageKey = GlobalKey<MyHomePageState>();
final FirebaseStorage storage = FirebaseStorage.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  await FirebaseApi().initNotifications();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final prefs = await SharedPreferences.getInstance();

  // await homePageKey.currentState?.loadImages();

  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoriteImagesProvider(prefs),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: true,
      themeMode: ThemeMode.system,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const AuthPage(),
      // home: DownloadAndUpload(),
      navigatorKey: navigatorKey,
      routes: {
        'notification_screen': (context) => const NotificationsPage(),
      },
    );
  }
}
