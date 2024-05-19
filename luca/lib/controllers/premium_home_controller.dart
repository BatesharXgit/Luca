import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PremiumHomeController extends GetxController
    with SingleGetTickerProviderMixin {
  final ScrollController scrollController = ScrollController();
  late TabController tabController;
  var isLoading = false.obs;

  var premiumData = [
    'Abstract',
    'Aesthetic',
    'Amoled',
    'Anime',
    'Digital Art',
    'Cars',
    'Cool Walls',
    'Dark Fantasy Art',
    'Foods',
    'Funny',
    'Homescreen',
    'Illustration',
    'Lockscreen',
    'Pixel Art',
    'Pop Art',
    'Superhero',
    'Text Wall',
    'Vivid Paint',
  ];

  var category = [
    'Abstract',
    'Aesthetic',
    'Amoled',
    'Anime',
    'Art',
    'Cars',
    'Cool',
    'Fantasy',
    'Foods',
    'Funny',
    'Homescreen',
    'Illustration',
    'Lockscreen',
    'PixelArt',
    'PopArt',
    'Superheroes',
    'TextWall',
    'Vivid',
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: premiumData.length, vsync: this);
  }
}
