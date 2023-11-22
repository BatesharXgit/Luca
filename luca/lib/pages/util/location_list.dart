import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:luca/pages/util/parallax.dart';
import 'package:shimmer/shimmer.dart';

class LocationListItem extends StatelessWidget {
  LocationListItem({
    Key? key,
    required this.imageUrl,
    required this.scrollController,
    Uint8List? imageBytes,
  }) : super(key: key);

  final String imageUrl;
  final ScrollController scrollController;

  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return _buildParallaxBackground(context);
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        CachedNetworkImage(
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 200),
          imageUrl: imageUrl,
          key: _backgroundImageKey,
          fit: BoxFit.cover,
          cacheManager: DefaultCacheManager(),
          placeholder: (context, url) => buildShimmerEffect(),
        ),
      ],
    );
  }

  Widget buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Colors.black,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.black,
            ),
          )),
    );
  }
}
