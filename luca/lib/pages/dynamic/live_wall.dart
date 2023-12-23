import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:async_wallpaper/async_wallpaper.dart';

//##############################################################################################################################
//##############################################################################################################################
//##############################################################################################################################

class CarsWallpaper extends StatefulWidget {
  const CarsWallpaper({super.key});

  @override
  _CarsWallpaperState createState() => _CarsWallpaperState();
}

class _CarsWallpaperState extends State<CarsWallpaper>
    with AutomaticKeepAliveClientMixin<CarsWallpaper> {
  PageController _pageController = PageController(viewportFraction: 0.8);
  List<String> videoUrls = [];
  int _currentVideoIndex = 0;
  VideoPlayerController? _controller;
  bool _isPlaying = true;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _fetchVideoUrls();
    _pageController.addListener(_onPageChange);
  }

  Future<void> _fetchVideoUrls() async {
    final storageRef = FirebaseStorage.instance.ref('live');
    final ListResult result = await storageRef.listAll();

    setState(() {
      videoUrls = result.items.map((item) => item.fullPath).toList();
    });

    _initializeVideoController(_currentVideoIndex);
  }

  void _initializeVideoController(int index) async {
    _controller?.dispose();
    final videoUrl = await _getVideoUrl(index);

    final cachedVideo = await DefaultCacheManager().getFileFromCache(videoUrl);

    if (cachedVideo != null && cachedVideo.file.existsSync()) {
      _controller = VideoPlayerController.file(cachedVideo.file)
        ..initialize().then((_) {
          setState(() {
            _videoInitialized = true;
          });
          _controller!.play();
          _controller!.setLooping(true);
          _isPlaying = true;
        });
    } else {
      var file = await DefaultCacheManager().getSingleFile(videoUrl);
      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {
            _videoInitialized = true;
          });
          _controller!.play();
          _controller!.setLooping(true);
          _isPlaying = true;
        });
    }

    _controller!.addListener(_onVideoStateChange);
  }

  Future<String> _getVideoUrl(int index) async {
    final ref = FirebaseStorage.instance.ref(videoUrls[index]);
    final url = await ref.getDownloadURL();
    return url;
  }

  void _onVideoStateChange() {
    if (_controller!.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _onPageChange() {
    int newPageIndex = _pageController.page!.toInt();
    if (newPageIndex != _currentVideoIndex &&
        newPageIndex >= 0 &&
        newPageIndex < videoUrls.length) {
      setState(() {
        _initializeVideoController(newPageIndex);
        _currentVideoIndex = newPageIndex;
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoStateChange);
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> applyLiveWallpaper(String videoUrl) async {
    String result;
    try {
      final httpUrl = await _getVideoUrl(_currentVideoIndex);

      var file = await DefaultCacheManager().getSingleFile(httpUrl);
      await _controller?.pause();
      result = await AsyncWallpaper.setLiveWallpaper(
        filePath: file.path,
      )
          ? 'Live wallpaper set'
          : 'Failed to set live wallpaper.';
    } catch (e) {
      print('Error applying live wallpaper: $e');
      result = 'Failed to set live wallpaper.';
    }
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          'Cars',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padEnds: true,
              controller: _pageController,
              itemCount: videoUrls.length,
              itemBuilder: (context, index) {
                return Center(
                  child: _videoInitialized && _controller != null
                      ? Visibility(
                          visible: index == _currentVideoIndex,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 100),
                            child: _controller!.value.isInitialized
                                ? AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 6),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: AspectRatio(
                                        aspectRatio:
                                            _controller!.value.aspectRatio,
                                        child: VideoPlayer(_controller!),
                                      ),
                                    ),
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      VideoPlayer(_controller!),
                                      const CircularProgressIndicator(),
                                    ],
                                  ),
                          ),
                        )
                      : const CircularProgressIndicator(),
                );
              },
            ),
          ),
          if (!_isPlaying && _videoInitialized)
            Center(
              child: IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  size: 48,
                ),
                onPressed: () {
                  setState(() {
                    _isPlaying = true;
                    _controller!.play();
                  });
                },
              ),
            ),
          GestureDetector(
            onTap: () async {
              if (_videoInitialized) {
                await applyLiveWallpaper(videoUrls[_currentVideoIndex]);
              }
            },
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Apply Wallpaper',
                  style: GoogleFonts.kanit(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

