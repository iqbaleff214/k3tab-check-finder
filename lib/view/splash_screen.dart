import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:k3tab_2023/util/color.dart';

final List<String> imgList = [
  'https://pbs.twimg.com/media/F6J-StEa4AAJAW2?format=jpg&name=4096x4096',
  'https://pbs.twimg.com/media/F6J-StDawAAJFjm?format=jpg&name=4096x4096',
  'https://pbs.twimg.com/media/F6J-StEbQAA-32k?format=jpg&name=4096x4096',
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: () => Navigator.pushReplacementNamed(context, "/home"),
                child: CarouselSlider(
                  options: CarouselOptions(
                      height: height,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5)),
                  items: imgList
                      .map((item) => Center(
                              child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF707070),
                              BlendMode.multiply,
                            ),
                            child: Image.network(
                              item,
                              fit: BoxFit.cover,
                              height: height,
                            ),
                          )))
                      .toList(),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.fact_check_outlined, size: 75, color: Colors.white,)
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CHECK",
                            style: GoogleFonts.poppins().copyWith(
                                fontWeight: FontWeight.bold,
                                color: orangeColor,
                                height: 1,
                                fontSize: 36),
                          ),
                          Text(
                            "FINDER",
                            style: GoogleFonts.poppins().copyWith(
                                fontWeight: FontWeight.bold,
                                color: whiteColor,
                                fontSize: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 300),
                  Center(
                    child: Text("MANUFACTURED BY: K3TAB POLIBAN 2023",
                        style: GoogleFonts.poppins().copyWith(
                            fontWeight: FontWeight.normal, color: whiteColor)),
                  )
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 270,
                  height: 70,
                  decoration: BoxDecoration(
                      color: whiteColor.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(150))),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 250,
                  height: 55,
                  decoration: const BoxDecoration(
                      color: orangeColor,
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(150))),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 200,
                  height: 45,
                  decoration: const BoxDecoration(
                    color: whiteColor,
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(150)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
