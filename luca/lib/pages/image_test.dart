import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/pages/util/location_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

Map<int, Uint8List> imageData = {};
List<int> requestedIndexes = [];

ScrollController scrollController = ScrollController();

class ImageScreen extends StatelessWidget {
  const ImageScreen({Key? key});

  Future<int> getImageCount() async {
    Reference photosReference =
        FirebaseStorage.instance.ref().child('wallpaper');
    ListResult result = await photosReference.listAll();
    return result.items.length;
  }

  Widget makeImagesGrid(int itemCount) {
    return GridView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75),
      itemBuilder: (context, index) {
        return ImageGridItem(index + 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getImageCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Components.buildPlaceholder();
        } else if (snapshot.hasError) {
          return Center(child: Text('Oops, something went wrong!'));
        } else {
          return Container(child: makeImagesGrid(snapshot.data!));
        }
      },
    );
  }
}

class ImageGridItem extends StatefulWidget {
  final int index;

  ImageGridItem(this.index, {Key? key}) : super(key: key);

  @override
  State<ImageGridItem> createState() => _ImageGridItemState();
}

class _ImageGridItemState extends State<ImageGridItem> {
  late Uint8List imageFile;
  late Reference photosReference;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    imageFile = Uint8List(0);
    photosReference = FirebaseStorage.instance.ref().child('wallpaper');
    if (!imageData.containsKey(widget.index)) {
      getImage();
    } else {
      setState(() {
        imageFile = imageData[widget.index]!;
      });
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> getImage() async {
    if (!requestedIndexes.contains(widget.index)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('${widget.index}')) {
        setState(() {
          imageFile = Uint8List.fromList(
              base64.decode(prefs.getString('${widget.index}')!));
        });
      } else {
        ListResult result = await photosReference.listAll();
        Reference imageReference = result.items[widget.index];

        Uint8List data = (await imageReference.getData()) ?? Uint8List(0);

        if (_mounted) {
          setState(() {
            imageFile = data;
          });
          imageData.putIfAbsent(widget.index, () {
            return data;
          });

          prefs.setString('${widget.index}', base64.encode(data));
        }
        requestedIndexes.add(widget.index);
      }
    }
  }

  Widget decideGridTileWidget() {
    return imageFile.isEmpty
        ? Components.buildShimmerEffect()
        : buildImageWidget(imageFile);
  }

  Widget buildImageWidget(Uint8List imageFile) {
    String base64String = base64Encode(imageFile);

    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ApplyWallpaperPage(imageUrl: base64String),
              ),
            );
          },
          child: Hero(
            tag: base64String, // Use a unique identifier here
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LocationListItem(
                  imageUrl: imageFile,
                  scrollController:
                      scrollController, // Assuming you have scrollController defined
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(child: decideGridTileWidget());
  }
}
