import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luca/livetest/controller.dart';
import 'package:video_player/video_player.dart';

class Player extends StatelessWidget {
  final int i;
  Player({Key? key, required this.i}) : super(key: key);

  final PCC c = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PCC>(
      initState: (x) async {
        if (c.api > 1) {
          await c.disposeController(c.api - 2);
        }
        if (c.api < c.videoPlayerControllers.length - 2) {
          await c.disposeController(c.api + 2);
        }
        if (!c.initializedIndexes.contains(i)) {
          await c.initializePlayer(i);
        }
        if (c.api > 0) {
          if (c.videoPlayerControllers[c.api - 1] == null) {
            await c.initializeIndexedController(c.api - 1);
          }
        }
        if (c.api < c.videoPlayerControllers.length - 1) {
          if (c.videoPlayerControllers[c.api + 1] == null) {
            await c.initializeIndexedController(c.api + 1);
          }
        }
      },
      dispose: (_) {
        if (c.videoPlayerControllers.isNotEmpty &&
            c.api >= 0 &&
            c.api < c.videoPlayerControllers.length &&
            c.videoPlayerControllers[c.api] != null) {
          c.videoPlayerControllers[c.api]!.dispose();
        }
      },
      builder: (_) {
        if (c.videoPlayerControllers.isEmpty ||
            c.api < 0 ||
            c.api >= c.videoPlayerControllers.length ||
            c.videoPlayerControllers[c.api] == null ||
            !c.videoPlayerControllers[c.api]!.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        if (i == c.api) {
          if (i < c.videoPlayerControllers.length) {
            if (c.videoPlayerControllers[c.api]!.value.isInitialized) {
              c.videoPlayerControllers[c.api]!.play();
              c.videoPlayerControllers[c.api]!.addListener(() {
                if (c.videoPlayerControllers[c.api]!.value.position ==
                    c.videoPlayerControllers[c.api]!.value.duration) {
                  c.videoPlayerControllers[c.api]!.seekTo(Duration.zero);
                  c.videoPlayerControllers[c.api]!.play();
                }
              });
            }
          }
          print('AutoPlaying ${c.api}');
        }
        return Stack(
          children: [
            c.videoPlayerControllers.isNotEmpty &&
                    c.videoPlayerControllers[c.api]!.value.isInitialized
                ? GestureDetector(
                    onTap: () {
                      if (c.videoPlayerControllers[c.api]!.value.isPlaying) {
                        print("paused");
                        c.videoPlayerControllers[c.api]!.pause();
                      } else {
                        c.videoPlayerControllers[c.api]!.play();
                        print("playing");
                      }
                    },
                    child: VideoPlayer(c.videoPlayerControllers[c.api]!),
                  )
                : const Center(child: CircularProgressIndicator()),
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  c.applyLiveWallpaper(i, c.videoPlayerControllers[c.api]);
                },
                child: const Text('Set Live Wallpaper'),
              ),
            ),
          ],
        );
      },
    );
  }
}
