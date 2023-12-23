import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luca/livetest/controller.dart';
import 'package:luca/livetest/player.dart';
import 'package:preload_page_view/preload_page_view.dart';

class PreloadPage extends StatelessWidget {
  const PreloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PCC());
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          child: PreloadPageView.builder(
            itemBuilder: (ctx, i) {
              return Player(i: i);
            },
            onPageChanged: (i) async {
              c.updateAPI(i);
            },
            preloadPagesCount: 1,
            controller: PreloadPageController(initialPage: 0),
            itemCount: c.videoURLs.length,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
