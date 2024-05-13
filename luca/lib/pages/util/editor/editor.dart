import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:image_editor/image_editor.dart' hide ImageSource;
import 'package:luca/pages/util/components.dart';
import 'package:luca/pages/util/editor/saveImage.dart';
import 'package:path_provider/path_provider.dart';

class EditWallpaper extends StatefulWidget {
  final String arguments;
  EditWallpaper({required this.arguments});
  @override
  _EditWallpaperState createState() => _EditWallpaperState();
}

class _EditWallpaperState extends State<EditWallpaper> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  double sat = 1;
  double bright = 0;
  double con = 1;

  final defaultColorMatrix = const <double>[
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0
  ];
  List<double> calculateSaturationMatrix(double saturation) {
    final m = List<double>.from(defaultColorMatrix);
    final invSat = 1 - saturation;
    final R = 0.213 * invSat;
    final G = 0.715 * invSat;
    final B = 0.072 * invSat;

    m[0] = R + saturation;
    m[1] = G;
    m[2] = B;
    m[5] = R;
    m[6] = G + saturation;
    m[7] = B;
    m[10] = R;
    m[11] = G;
    m[12] = B + saturation;

    return m;
  }

  List<double> calculateContrastMatrix(double contrast) {
    final m = List<double>.from(defaultColorMatrix);
    m[0] = contrast;
    m[6] = contrast;
    m[12] = contrast;
    return m;
  }

  // File? image;
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    // image = widget.arguments[0];
    imageUrl = widget.arguments;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Edit Image",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings_backup_restore),
              onPressed: () {
                setState(() {
                  sat = 1;
                  bright = 0;
                  con = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                await saveImage();
              },
            ),
          ]),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Fullscreen image
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: buildImage(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  color: Colors.white.withOpacity(0.15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSat(),
                      SizedBox(
                        height: 4,
                      ),
                      _buildBrightness(),
                      SizedBox(
                        height: 4,
                      ),
                      _buildCon(),
                      SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(calculateContrastMatrix(con)),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(calculateSaturationMatrix(sat)),
        child: ExtendedImage(
          color: bright > 0
              ? Colors.white.withOpacity(bright)
              : Colors.black.withOpacity(-bright),
          colorBlendMode: bright > 0 ? BlendMode.lighten : BlendMode.darken,
          handleLoadingProgress: true,
          image: ExtendedNetworkImageProvider(
            imageUrl!,
            cacheRawData: true,
          ),
          extendedImageEditorKey: editorKey,
          mode: ExtendedImageMode.editor,
          fit: BoxFit.contain,
          initEditorConfigHandler: (ExtendedImageState? state) {
            return EditorConfig(
              maxScale: 8.0,
              cropRectPadding: const EdgeInsets.all(0),
            );
          },
          loadStateChanged: (ExtendedImageState state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                return Components.buildShimmerEffect(context);
              case LoadState.completed:
                return null;
              case LoadState.failed:
                return Components.buildErrorWidget();
            }
          },
        ),
      ),
    );
  }

  Future<void> saveImage([bool test = false]) async {
    final ExtendedImageEditorState state = editorKey.currentState!;
    final Uint8List img = state.rawImageData;

    final ImageEditorOption option = ImageEditorOption();
    // Adjust color options as needed
    option.addOption(ColorOption.saturation(sat));
    option.addOption(ColorOption.brightness(bright + 1));
    option.addOption(ColorOption.contrast(con));
    option.outputFormat = const OutputFormat.jpeg(100);

    final DateTime start = DateTime.now();
    final Uint8List? result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    final Duration diff = DateTime.now().difference(start);
    print('image_editor time : $diff');

    // Pass the edited image data to the next screen
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => ApplyWalls(
          editedImageBytes: result,
        ),
      ),
    );
  }

  Widget _buildSat() {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(
              Icons.brush,
              color: primaryColor,
            ),
            Text(
              "Saturation",
              style: TextStyle(color: primaryColor),
            )
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: 'sat : ${sat.toStringAsFixed(2)}',
            onChanged: (double value) {
              setState(() {
                sat = value;
              });
            },
            value: sat,
            min: 0,
            max: 2,
          ),
        ),
        Text(sat.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildBrightness() {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(
              Icons.brightness_4,
              color: primaryColor,
            ),
            Text(
              "Brightness",
              style: TextStyle(color: primaryColor),
            )
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: '${bright.toStringAsFixed(2)}',
            onChanged: (double value) {
              setState(() {
                bright = value;
              });
            },
            value: bright,
            min: -1,
            max: 1,
          ),
        ),
        Text(bright.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildCon() {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(
              Icons.color_lens,
              color: primaryColor,
            ),
            Text(
              "  Contrast  ",
              style: TextStyle(color: primaryColor),
            )
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: 'con : ${con.toStringAsFixed(2)}',
            value: con,
            min: 0,
            max: 4,
            onChanged: (double value) {
              setState(() {
                con = value;
              });
            },
          ),
        ),
        Text(con.toStringAsFixed(2)),
      ],
    );
  }
}
