import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:luca/pages/util/apply_walls.dart';
import 'package:luca/pages/util/components.dart';
import 'package:luca/services/admob_service.dart';

import 'walls_category.dart';

class Category extends StatefulWidget {
  const Category({
    Key? key,
  }) : super(key: key);

  @override
  State<Category> createState() => CategoryState();
}

class CategoryState extends State<Category> {
  final List<String> _amoled = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F160.jpg?alt=media&token=306a248b-0f96-408d-b442-6cfb5e732720',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F166.jpg?alt=media&token=ff265cb6-bcf8-4f75-9873-76328dbaec3c',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F191.jpg?alt=media&token=a5b5b4d8-1ab4-48e4-966c-782e508857f0',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F171.jpg?alt=media&token=1e25ccfa-a8c8-40b8-b427-c8e772d4c9d5',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Famoled%2F192.jpg?alt=media&token=c051e0f8-34af-4137-9acc-db46ef44e409',
  ];

  final List<String> _abstract = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fabstract%2F163.jpg?alt=media&token=539569a2-682a-4d8b-8f7b-7c039af8d7d1',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fabstract%2F188.jpg?alt=media&token=556ebee4-2842-4f7a-945e-e53655851385',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fabstract%2F167.jpg?alt=media&token=f1f08fa0-b6bf-47bb-9e75-f9866bd1b856',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fabstract%2F172.jpg?alt=media&token=4ece2a66-85f5-4054-be9e-9a381ee58de4',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fabstract%2F164.jpg?alt=media&token=d86e62e7-ffa4-45e3-a41b-5bf89de4aca7',
  ];

  final List<String> _ai = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fai%2F183.png?alt=media&token=2d194148-837c-4176-b379-7c353991a48e',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fai%2F178.jpg?alt=media&token=0d5170a4-3872-4f4f-8250-d75dd8e4ef34',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fai%2F172.jpg?alt=media&token=81acf915-fd04-404d-bd38-7325dbcc51e5',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fai%2F187.jpg?alt=media&token=68ce63f6-78be-40dc-bd8d-6202f57b030e',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fai%2F197.jpg?alt=media&token=d88430f5-0102-4821-8258-e976dc575e8a',
  ];

  final List<String> _cars = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fcars%2F177.jpg?alt=media&token=d0b243eb-ade1-461c-a28f-1e955bae4f1d',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fcars%2F148.jpg?alt=media&token=03580e26-ac1e-4fc3-b34c-3f80e42f725e',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fcars%2F189.jpg?alt=media&token=0faebe5b-e513-40a9-a54b-5a339706e225',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fcars%2F185.jpg?alt=media&token=98277b36-f259-4c04-8b68-fadb7e9f7910',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fcars%2F182.jpg?alt=media&token=847d8303-3763-45fb-afac-bfae525a7ea0',
  ];

  final List<String> _illustration = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fillustration%2F137.jpg?alt=media&token=b7b15bef-4d64-4953-96b1-4468caf1c06e',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fillustration%2F141.jpg?alt=media&token=255c4cfd-46e6-435d-a4cf-fef97e78eced',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fillustration%2F154.jpg?alt=media&token=d88095e0-dae4-4c7d-8dd7-c88ad3c60959',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fillustration%2F173.jpg?alt=media&token=59692cad-738b-4099-94f2-0d8eb40c1809',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fillustration%2F174.jpg?alt=media&token=14ce5404-d5a0-48d2-b43f-8a6321ed1e12',
  ];

  final List<String> _space = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F150.jpg?alt=media&token=57254b59-3ad6-4e03-b5d2-2cc7930487b5',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F148.jpg?alt=media&token=cd7414fb-707d-477a-a284-fb86371aed87',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F165.jpg?alt=media&token=8f49b981-7574-405a-b695-27537ade97d9',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F167.jpg?alt=media&token=d0a88e13-46b4-4faa-876c-ac7079e28f38',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fspace%2F188.jpg?alt=media&token=c2f57579-938f-4e12-bbe9-3bc1cf93df99',
  ];

  final List<String> _superheroes = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fsuperheroes%2F181.jpg?alt=media&token=deb248de-6014-4241-9893-e5693c2be324',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fsuperheroes%2F200.jpg?alt=media&token=72507850-6ee1-4911-a4a7-3bba53773b91',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fsuperheroes%2F182.jpg?alt=media&token=a665b97b-3c56-4424-a069-4fc596da8118',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fsuperheroes%2F186.jpg?alt=media&token=72c14a9c-e869-4714-9764-a80654f8ad3d',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fsuperheroes%2F198.jpg?alt=media&token=bd1f03d8-415f-4692-801a-b9c929068441',
  ];

  final List<String> _devotional = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fdevotional%2F173.jpg?alt=media&token=c02f01d0-bd4e-4017-bf5f-5644150441c9',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fdevotional%2F175.jpg?alt=media&token=341c4ace-79ca-48f7-a24b-e22939bb3fc2',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fdevotional%2F192.jpg?alt=media&token=9ec57f86-21ec-4b06-92c8-34d0d428e6b7',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fdevotional%2F190.jpg?alt=media&token=a2bf830b-4b0d-4ebb-a4ce-25fff94353e8',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fdevotional%2F197.jpg?alt=media&token=650c3b7e-4867-4939-8829-a66f3e40f910',
  ];

  final List<String> _anime = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F171.png?alt=media&token=249aeb62-5404-461b-a558-db9969e1a390',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F172.jpg?alt=media&token=477f5b67-8af5-4db8-8054-b979b21fbeec',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F173.jpg?alt=media&token=8b0ce0b8-4bf5-4ebb-b4e3-b97ceb250437',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F174.jpg?alt=media&token=12d722c6-5f4b-440b-add7-286e6b1b14cc',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanime%2F175.jpg?alt=media&token=106ec70d-53c3-40f0-b512-d4494188978c',
  ];

  final List<String> _minimalist = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F151.jpg?alt=media&token=dafc7804-3bfe-4679-b764-46782983dc51',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F161.jpg?alt=media&token=47de1228-ec24-48af-92f6-2f0e78f81625',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F187.jpg?alt=media&token=8620fc99-8845-4548-bb57-a474ea3231a7',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F181.jpg?alt=media&token=9da207df-d28c-44c4-8b23-513ccb9e0c6e',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fminimalist%2F176.jpg?alt=media&token=ab85a721-1a61-4c6b-8fbc-65a6ed005e3e',
  ];

  final List<String> _nature = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F197.jpg?alt=media&token=18b20fe5-2742-4fa5-97e1-1890f26725c7',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F180.jpg?alt=media&token=7094f577-59d1-4afc-a000-52eb00252fac',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F175.jpg?alt=media&token=3d799b73-26e1-483d-845e-9ff407b9b134',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F166.png?alt=media&token=a03d37c9-f18d-4762-9a97-a50adb1588f4',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fnature%2F176.jpg?alt=media&token=de40322f-ad31-466a-a07b-c307a2090ad9',
  ];

  final List<String> _animals = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F183.jpg?alt=media&token=b3628c54-4724-4c7a-899b-b7de64a7ac20',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F186.jpg?alt=media&token=55937102-e076-4388-a159-869375974d05',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F190.png?alt=media&token=9e235cbe-c66a-4c91-b270-a9c1bfe29119',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F177.png?alt=media&token=37073299-d145-4a3f-89cc-0a15734ac4ae',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fanimals%2F196.jpg?alt=media&token=32555a4f-3ed7-44a1-a746-428a3d26011d',
  ];

  final List<String> _scifi = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F184.jpg?alt=media&token=902cbeee-d7b8-4deb-9fdf-df4695112db6',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F198.jpg?alt=media&token=657641ad-41c1-451c-ad20-067930340db5',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F179.jpg?alt=media&token=24e5aa69-9971-4d1b-b727-d02b756b99de',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F192.jpg?alt=media&token=3b0a4257-0688-477b-9c9b-c73014c104c1',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fscifi%2F191.jpg?alt=media&token=0fd58cd3-87d9-4fbe-9e44-a04f8bea1fa9',
  ];

  final List<String> _games = [
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F144.jpg?alt=media&token=a68a12e6-b0b6-409d-b175-b67c7e73ef53',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F174.jpg?alt=media&token=869826cb-184e-4b5d-8055-f422ab82938b',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F150.jpg?alt=media&token=81b9fce8-e854-4715-8f23-1b2b191b46ca',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F155.jpg?alt=media&token=fb17e567-39cd-465d-a453-e91196873bb9',
    'https://firebasestorage.googleapis.com/v0/b/luca-ui.appspot.com/o/category%2Fgames%2F170.jpg?alt=media&token=fa24c295-84ec-4b0e-bfc3-985ad83b988b',
  ];

  late bool _isNatureLoaded = false;
  late bool _isAbstractLoaded = false;
  late bool _isCarsLoaded = false;
  late bool _isIllustrationLoaded = false;
  late bool _isAiLoaded = false;
  late bool _isSpaceLoaded = false;
  late bool _isSuperheroesLoaded = false;
  late bool _isDevotionalLoaded = false;
  late bool _isMinimalLoaded = false;
  late bool _isAnimeLoaded = false;
  late bool _isAnimalsLoaded = false;
  late bool _isSciFiLoaded = false;
  late bool _isGamesLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isNatureLoaded = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        _isSuperheroesLoaded = true;
        _isDevotionalLoaded = true;
        _isAbstractLoaded = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _isSpaceLoaded = true;
        _isMinimalLoaded = true;
        _isCarsLoaded = true;
      });
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isIllustrationLoaded = true;
        _isAnimeLoaded = true;
        _isAnimalsLoaded = true;
      });
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isAiLoaded = true;
        _isSciFiLoaded = true;
        _isGamesLoaded = true;
      });
    });
    _createInterstitialAd();
  }

  InterstitialAd? _interstitialAd;

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.wallOpeninterstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          Future.delayed(const Duration(minutes: 1), () {
            _createInterstitialAd();
          });
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          Future.delayed(const Duration(minutes: 1), () {
            _createInterstitialAd();
          });
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    // Color secondaryColor = Theme.of(context).colorScheme.secondary;
    // Color tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Scaffold(
      appBar: AppBar(
        // elevation: 0,
        // centerTitle: true,

        backgroundColor: backgroundColor,
        title: Text(
          'Categories',
          style: GoogleFonts.kanit(
            color: primaryColor,
            fontSize: 22,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimationLimiter(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 200),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amoled",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'amoled',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: 5,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApplyWallpaperPage(
                                        imageUrl: _amoled[index]),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 280,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CachedNetworkImage(
                                    fadeInDuration:
                                        const Duration(milliseconds: 200),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 200),
                                    imageUrl: _amoled[index],
                                    placeholder: (context, url) =>
                                        Components.buildShimmerEffect(context),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Abstract",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'abstract',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isAbstractLoaded)
                          ? ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _abstract[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 150,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _abstract[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cars",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'cars',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isCarsLoaded)
                          ? ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _cars[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 280,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _cars[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Illustration",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'illustration',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isIllustrationLoaded)
                          ? ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl:
                                                      _illustration[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 150,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _illustration[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "AI",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'ai',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isAiLoaded)
                          ? ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _ai[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 280,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _ai[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nature",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'nature',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isNatureLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _nature[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 150,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _nature[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "SuperHeroes",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'superheroes',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isSuperheroesLoaded)
                          ? ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl:
                                                      _superheroes[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 280,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _superheroes[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Devotional",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'devotional',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isDevotionalLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _devotional[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 150,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _devotional[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Space",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'space',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isSpaceLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 280,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ApplyWallpaperPage(
                                                    imageUrl: _space[index]),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _space[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Minimalist",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'minimalist',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isMinimalLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 150,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ApplyWallpaperPage(
                                                    imageUrl:
                                                        _minimalist[index]),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _minimalist[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Anime",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'anime',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isAnimeLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 280,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ApplyWallpaperPage(
                                                    imageUrl: _anime[index]),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          // imageUrl: _stock[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          imageUrl: _anime[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Animals",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'animals',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isAnimalsLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _animals[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 150,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _animals[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sci-Fi",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'scifi',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isSciFiLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _scifi[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 280,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _scifi[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Games",
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInterstitialAd();
                            Get.to(const WallpapersCategory(
                              category: 'games',
                            ));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: SizedBox(
                      height: 300,
                      child: (_isGamesLoaded)
                          ? ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ApplyWallpaperPage(
                                                  imageUrl: _games[index]),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 150,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 200),
                                          imageUrl: _games[index],
                                          placeholder: (context, url) =>
                                              Components.buildShimmerEffect(
                                                  context),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
