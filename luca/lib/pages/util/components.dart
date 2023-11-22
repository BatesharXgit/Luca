import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:luca/pages/static/walls_category.dart';
import 'package:shimmer/shimmer.dart';

class Components {
  static Widget buildImageWidget(String imageUrl) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ApplyWallpaperPage(imageUrl: imageUrl),
              ),
            );
          },
          child: Hero(
            tag: imageUrl,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LocationListItem(
                  imageUrl: imageUrl,
                  scrollController: scrollController,
                  imageBytes: null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget buildPlaceholder() {
    return Builder(builder: (context) {
      return Center(
        child: LoadingAnimationWidget.newtonCradle(
          size: 35,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    });
  }

  static Widget buildErrorWidget() {
    return Container(
      color: Colors.transparent,
      child: const Icon(
        Icons.error,
        color: Colors.red,
      ),
    );
  }

  static Widget buildCircularIndicator() {
    return Builder(builder: (context) {
      return Center(
        child: LoadingAnimationWidget.fallingDot(
          size: 35,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    });
  }

  static Widget buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Builder(builder: (context) {
        return Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.tertiary,
            highlightColor: Theme.of(context).colorScheme.primary,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Theme.of(context).colorScheme.background,
              ),
            ));
      }),
    );
  }
}
