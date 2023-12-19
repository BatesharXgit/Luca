import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PCC extends GetxController {
  int _api = 0;
  List<VideoPlayerController?> videoPlayerControllers = [];
  List<int> initializedIndexes = [];
  bool autoplay = true;
  int get api => _api;
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  void updateAPI(int i) {
    if (_api >= 0 &&
        _api < videoPlayerControllers.length &&
        videoPlayerControllers[_api] != null) {
      videoPlayerControllers[_api]!.pause();
    }
    _api = i;
    update();
  }

  Future initializePlayer(int i) async {
    print('initializing $i');
    if (i >= 0 && i < videoURLs.length) {
      late VideoPlayerController singleVideoController;

      // Use cache manager for video URL caching
      var file = await cacheManager.getSingleFile(videoURLs[i]);
      singleVideoController = VideoPlayerController.file(file);

      // Ensure the list is long enough to accommodate the index
      while (videoPlayerControllers.length <= i) {
        videoPlayerControllers.add(null);
      }

      videoPlayerControllers[i] = singleVideoController;
      initializedIndexes.add(i);

      // Check if the controller is not null before initializing
      if (videoPlayerControllers[i] != null) {
        await videoPlayerControllers[i]!.initialize();
      }

      update();
    }
  }

  Future initializeIndexedController(int index) async {
    if (index >= 0 && index < videoURLs.length) {
      late VideoPlayerController singleVideoController;

      // Use cache manager for video URL caching
      var file = await cacheManager.getSingleFile(videoURLs[index]);
      singleVideoController = VideoPlayerController.file(file);

      videoPlayerControllers[index] = singleVideoController;
      await videoPlayerControllers[index]!.initialize();
      update();
    }
  }

  Future disposeController(int i) async {
    if (i >= 0 &&
        i < videoPlayerControllers.length &&
        videoPlayerControllers[i] != null) {
      await videoPlayerControllers[i]!.dispose();
      videoPlayerControllers[i] = null;
    }
  }

  void disposeCacheManager() {
    cacheManager.dispose();
  }

  final List<String> videoURLs = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/live%2F1.mp4?alt=media&token=123fef53-8b10-45b4-92d6-ea16939fe395',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/live%2F2.mp4?alt=media&token=b3f46499-6a9f-4df8-9657-4409c3565cf0',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/live%2F3.mp4?alt=media&token=a420bc7f-7aa4-4864-aeb4-a1b5300a770c',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/live%2F6.mp4?alt=media&token=04fef9a1-afbf-4dd0-a71b-38de8a3512a5',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/live%2F7.mp4?alt=media&token=17688c53-5687-4f21-8b30-656683992a00',
  ];
}
