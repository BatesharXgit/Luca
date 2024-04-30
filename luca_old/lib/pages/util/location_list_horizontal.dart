import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/pages/util/parallax_horizontal.dart';

class LocationListItemHorizontal extends StatelessWidget {
  LocationListItemHorizontal({
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
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        CachedNetworkImage(
          fadeInDuration: const Duration(milliseconds: 50),
          fadeOutDuration: const Duration(milliseconds: 50),
          imageUrl: imageUrl,
          key: _backgroundImageKey,
          fit: BoxFit.fill,
          // cacheManager: DefaultCacheManager(),
          placeholder: (context, url) => Components.buildShimmerEffect(context),
        ),
      ],
    );
  }
}
