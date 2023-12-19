import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveWallCategory extends StatefulWidget {
  const LiveWallCategory({
    Key? key,
  
  }) : super(key: key);

  @override
  State<LiveWallCategory> createState() => _LiveWallCategoryState();
}

class _LiveWallCategoryState extends State<LiveWallCategory> {
  final List<String> categories = [
    'Cars',
    'Anime',
    'Nature',
    'CyberWorld',
    'Games',
    'Fantasy',
    'Environments',
    'Abstract',
    'Aquatic',
    'Space',
    'Technology',
    'Animals',
  ];

  final List<String> images = [
    'https://i.pinimg.com/564x/41/75/52/417552160591a2f8f474f05c11c051cf.jpg',
    'https://i.pinimg.com/564x/a3/64/47/a3644706edd2f2f2ae457ea4cce747ff.jpg',
    'https://i.pinimg.com/564x/88/42/6a/88426a84230264df2ffa1cb007e8bd56.jpg',
    'https://i.pinimg.com/564x/3e/4e/92/3e4e92719b983df8f3ac0674d80a83a6.jpg',
    'https://i.pinimg.com/564x/c7/6c/26/c76c26fd2c0ec8bcbaa7bb7ebb68881c.jpg',
    'https://i.pinimg.com/564x/19/4a/37/194a37a3b214b113aedccaaac4f70956.jpg',
    'https://i.pinimg.com/564x/fe/d4/54/fed454e0dca948c101c8b84658767126.jpg',
    'https://i.pinimg.com/564x/1b/77/3f/1b773f7322c4512076b0140c30ddf36c.jpg',
    'https://i.pinimg.com/564x/9a/d8/c1/9ad8c1eb0e8a829768053011cc191723.jpg',
    'https://i.pinimg.com/564x/5e/54/54/5e5454fb45337d754aa77c5d3807b3e1.jpg',
    'https://i.pinimg.com/564x/1e/a6/2e/1ea62ec38bb580fd47f0caa9e8b9afef.jpg',
    'https://i.pinimg.com/564x/68/04/a6/6804a66bfb44a32ffb1a4a948971d462.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundColor,
        title: Text(
          'Live Wallpapers',
          style: GoogleFonts.orbitron(
            color: primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 24, 24, 24),
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: NetworkImage(images[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 60,
                                  left: 60,
                                  top: MediaQuery.of(context).padding.top + 200,
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      categories[index],
                                      style: GoogleFonts.kanit(
                                        color: primaryColor,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
