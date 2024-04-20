import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StockCategories extends StatefulWidget {
  final ScrollController controller;
  const StockCategories({required this.controller, super.key});

  @override
  State<StockCategories> createState() => _StockCategoriesState();
}

class _StockCategoriesState extends State<StockCategories> {
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    Color tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Scaffold(
      appBar: AppBar(
        // elevation: 0,
        // centerTitle: true,

        backgroundColor: backgroundColor,
        title: Text(
          'Stock Wallpapers',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
