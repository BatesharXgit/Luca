import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luca/pages/util/components.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final Reference amoledRef = storage.ref().child('category/amoled');
final Reference spaceRef = storage.ref().child('category/space');
final Reference animeRef = storage.ref().child('category/anime');
final Reference minimalistRef = storage.ref().child('category/minimalist');
final Reference natureRef = storage.ref().child('category/nature');
final Reference animalsRef = storage.ref().child('category/animals');
final Reference scifiRef = storage.ref().child('category/scifi');
final Reference gamesRef = storage.ref().child('category/games');
final Reference superheroesRef = storage.ref().child('category/superheroes');
final Reference devotionalRef = storage.ref().child('category/devotional');
final Reference editorsRef = storage.ref().child('category/editors');

ScrollController scrollController = ScrollController();

//=====================================================================================================================
//===============================================  Amoled Wallpaper ===================================================
//=====================================================================================================================
class AmoledWallpaper extends StatefulWidget {
  const AmoledWallpaper({super.key});

  @override
  State<AmoledWallpaper> createState() => _AmoledWallpaperState();
}

class _AmoledWallpaperState extends State<AmoledWallpaper> {
  List<Reference> amoledRefs = [];
  @override
  void initState() {
    super.initState();
    loadamoledImages();
  }

  Future<void> loadamoledImages() async {
    final ListResult result = await amoledRef.listAll();
    amoledRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    // Color secondaryColor = Theme.of(context).colorScheme.secondary;
    // Color tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          'Amoled',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: amoledRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: amoledRefs.length,
                      itemBuilder: (context, index) {
                        final amoRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: amoRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//=====================================================================================================================
//===============================================  Space Wallpaper ===================================================
//=====================================================================================================================
class SpaceWallpaper extends StatefulWidget {
  const SpaceWallpaper({super.key});

  @override
  State<SpaceWallpaper> createState() => _SpaceWallpaperState();
}

class _SpaceWallpaperState extends State<SpaceWallpaper> {
  List<Reference> spaceRefs = [];

  @override
  void initState() {
    super.initState();
    loadspaceImages();
  }

  Future<void> loadspaceImages() async {
    final ListResult result = await spaceRef.listAll();
    spaceRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          'Space',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: spaceRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: spaceRefs.length,
                      itemBuilder: (context, index) {
                        final imageRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: imageRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//=====================================================================================================================
//===============================================  Anime Wallpaper ===================================================
//=====================================================================================================================

class AnimeWallpapers extends StatefulWidget {
  const AnimeWallpapers({super.key});

  @override
  State<AnimeWallpapers> createState() => _AnimeWallpapersState();
}

class _AnimeWallpapersState extends State<AnimeWallpapers> {
  List<Reference> animeRefs = [];

  @override
  void initState() {
    super.initState();
    loadAnimeImages();
  }

  Future<void> loadAnimeImages() async {
    final ListResult result = await animeRef.listAll();
    animeRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          'Anime',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: animeRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: animeRefs.length,
                      itemBuilder: (context, index) {
                        final imageRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: imageRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//=====================================================================================================================
//===============================================  Minimalist Wallpaper ===============================================
//=====================================================================================================================
class MinimalistWallpaper extends StatefulWidget {
  const MinimalistWallpaper({super.key});

  @override
  State<MinimalistWallpaper> createState() => _MinimalistWallpaperState();
}

class _MinimalistWallpaperState extends State<MinimalistWallpaper> {
  List<Reference> minimalistRefs = [];

  @override
  void initState() {
    super.initState();
    loadminimalistImages();
  }

  Future<void> loadminimalistImages() async {
    final ListResult result = await minimalistRef.listAll();
    minimalistRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          'Minimalist',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: minimalistRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: minimalistRefs.length,
                      itemBuilder: (context, index) {
                        final imageRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: imageRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//=====================================================================================================================
//===============================================  Nature Wallpaper ===================================================
//=====================================================================================================================

class NatureWallpaper extends StatefulWidget {
  const NatureWallpaper({super.key});

  @override
  State<NatureWallpaper> createState() => _NatureWallpaperState();
}

class _NatureWallpaperState extends State<NatureWallpaper> {
  List<Reference> natureRefs = [];

  @override
  void initState() {
    super.initState();
    loadnatureImages();
  }

  Future<void> loadnatureImages() async {
    final ListResult result = await natureRef.listAll();
    natureRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          'Nature',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: natureRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: natureRefs.length,
                      itemBuilder: (context, index) {
                        final imageRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: imageRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//=====================================================================================================================
//===============================================  Animals Wallpaper ===================================================
//=====================================================================================================================

class AnimalsWallpaper extends StatefulWidget {
  const AnimalsWallpaper({super.key});

  @override
  State<AnimalsWallpaper> createState() => _AnimalsWallpaperState();
}

class _AnimalsWallpaperState extends State<AnimalsWallpaper> {
  List<Reference> animalsRefs = [];

  @override
  void initState() {
    super.initState();
    loadanimalsImages();
  }

  Future<void> loadanimalsImages() async {
    final ListResult result = await animalsRef.listAll();
    animalsRefs = result.items.toList();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          'Animals',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: animalsRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: animalsRefs.length,
                      itemBuilder: (context, index) {
                        final imageRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: imageRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//=====================================================================================================================
//===============================================  SciFi Wallpaper ===================================================
//=====================================================================================================================

class ScifiWallpaper extends StatefulWidget {
  const ScifiWallpaper({super.key});

  @override
  State<ScifiWallpaper> createState() => _ScifiWallpaperState();
}

class _ScifiWallpaperState extends State<ScifiWallpaper> {
  List<Reference> scifiRefs = [];

  @override
  void initState() {
    super.initState();
    loadscifiImages();
  }

  Future<void> loadscifiImages() async {
    final ListResult result = await scifiRef.listAll();
    scifiRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          'Sci - Fi',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: scifiRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: scifiRefs.length,
                      itemBuilder: (context, index) {
                        final imageRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: imageRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//=====================================================================================================================
//===============================================  Games Wallpaper ===================================================
//=====================================================================================================================

class GamesWallpaper extends StatefulWidget {
  const GamesWallpaper({super.key});

  @override
  State<GamesWallpaper> createState() => _GamesWallpaperState();
}

class _GamesWallpaperState extends State<GamesWallpaper> {
  List<Reference> gamesRefs = [];
  @override
  void initState() {
    super.initState();
    loadgamesImages();
  }

  Future<void> loadgamesImages() async {
    final ListResult result = await gamesRef.listAll();
    gamesRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          'Games',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: gamesRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: gamesRefs.length,
                      itemBuilder: (context, index) {
                        final imageRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: imageRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuperheroesWallpaper extends StatefulWidget {
  const SuperheroesWallpaper({super.key});

  @override
  State<SuperheroesWallpaper> createState() => _SuperheroesWallpaper();
}

class _SuperheroesWallpaper extends State<SuperheroesWallpaper> {
  List<Reference> superheroesRefs = [];
  @override
  void initState() {
    super.initState();
    loadamoledImages();
  }

  Future<void> loadamoledImages() async {
    final ListResult result = await superheroesRef.listAll();
    superheroesRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    // Color secondaryColor = Theme.of(context).colorScheme.secondary;
    // Color tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          'Super Heroes',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: superheroesRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: superheroesRefs.length,
                      itemBuilder: (context, index) {
                        final amoRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: amoRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DevotionalWallpaper extends StatefulWidget {
  const DevotionalWallpaper({super.key});

  @override
  State<DevotionalWallpaper> createState() => _DevotionalWallpaper();
}

class _DevotionalWallpaper extends State<DevotionalWallpaper> {
  List<Reference> devotionalRefs = [];
  @override
  void initState() {
    super.initState();
    loadamoledImages();
  }

  Future<void> loadamoledImages() async {
    final ListResult result = await devotionalRef.listAll();
    devotionalRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    // Color secondaryColor = Theme.of(context).colorScheme.secondary;
    // Color tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          'Devotional',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: devotionalRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: devotionalRefs.length,
                      itemBuilder: (context, index) {
                        final amoRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: amoRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditorPick extends StatefulWidget {
  const EditorPick({super.key});

  @override
  State<EditorPick> createState() => _EditorPickState();
}

class _EditorPickState extends State<EditorPick> {
  List<Reference> editorsRefs = [];
  @override
  void initState() {
    super.initState();
    loadgamesImages();
  }

  Future<void> loadgamesImages() async {
    final ListResult result = await editorsRef.listAll();
    editorsRefs = result.items.toList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColor,
        title: Text(
          'Editor\'s Pick',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<ListResult>(
                future: editorsRef.listAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Components.buildPlaceholder();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    List<Reference> imageRefs = snapshot.data!.items;

                    return GridView.builder(
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: editorsRefs.length,
                      itemBuilder: (context, index) {
                        final imageRef = imageRefs[index];
                        return FutureBuilder<String>(
                          future: imageRef.getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Components.buildShimmerEffect(context);
                            } else if (snapshot.hasError) {
                              return Components.buildErrorWidget();
                            } else if (snapshot.hasData) {
                              return Components.buildImageWidget(
                                  snapshot.data!);
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No images available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
