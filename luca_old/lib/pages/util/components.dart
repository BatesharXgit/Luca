import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:luca/pages/static/walls_category.dart';
import 'package:shimmer/shimmer.dart';

class Components {
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

  static Widget buildShimmerEffect(context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: backgroundColor,
          highlightColor: primaryColor,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: primaryColor,
            ),
          )),
    );
  }
}
