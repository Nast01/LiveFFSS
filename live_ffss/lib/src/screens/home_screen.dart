import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_ffss/src/controllers/authentication_controller.dart';
import 'package:getwidget/getwidget.dart';

class HomeScreen extends StatelessWidget {
  final AuthenticationController _controller =
      Get.put(AuthenticationController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List list = [
      "Flutter",
      "React",
      "Ionic",
      "Xamarin",
    ];

    return Scaffold(
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/images/logo_ffss.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                Text(
                  "LIVE FFSS !",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GFSearchBar(
                    searchList: list,
                    searchQueryBuilder: (query, list) {
                      return list
                          .where((item) =>
                              item.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                    },
                    overlaySearchListItemBuilder: (item) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 50.0,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        GFButton(
                          onPressed: () {},
                          text: "TOUS",
                          type: GFButtonType.outline2x,
                          textStyle: GoogleFonts.poppins(
                              color: const Color(0xFF006FFD),
                              fontWeight: FontWeight.bold),
                          shape: GFButtonShape.pills,
                          size: GFSize.SMALL,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GFButton(
                          onPressed: () {},
                          text: "EAU PLATE",
                          type: GFButtonType.outline2x,
                          textStyle: GoogleFonts.poppins(
                              color: const Color(0xFF006FFD),
                              fontWeight: FontWeight.bold),
                          shape: GFButtonShape.pills,
                          size: GFSize.SMALL,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GFButton(
                          onPressed: () {},
                          text: "COTIER",
                          type: GFButtonType.outline2x,
                          textStyle: GoogleFonts.poppins(
                              color: const Color(0xFF006FFD),
                              fontWeight: FontWeight.bold),
                          shape: GFButtonShape.pills,
                          size: GFSize.SMALL,
                        ),
                      ],
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: () {},
                //   child: Container(
                //     width: 90,
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: const Color(0xFFEAF2FF), // Couleur de fond
                //       borderRadius:
                //           BorderRadius.circular(8), // Rayon des coins arrondis
                //     ),
                //     child: Text(
                //       "TOUS",
                //       textAlign: TextAlign.center,
                //       style: GoogleFonts.poppins(
                //           color: const Color(0xFF006FFD),
                //           fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // ),
                // TextButton(
                //   onPressed: () {},
                //   child: Container(
                //     width: 90,
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: const Color(0xFFEAF2FF), // Couleur de fond
                //       borderRadius:
                //           BorderRadius.circular(8), // Rayon des coins arrondis
                //     ),
                //     child: Text(
                //       "EAU PLATE",
                //       textAlign: TextAlign.center,
                //       style: GoogleFonts.poppins(
                //           color: const Color(0xFF006FFD),
                //           fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // ),
                // TextButton(
                //   onPressed: () {},
                //   child: Container(
                //     width: 80,
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: const Color(0xFFEAF2FF), // Couleur de fond
                //       borderRadius:
                //           BorderRadius.circular(8), // Rayon des coins arrondis
                //     ),
                //     child: Text(
                //       "COTIER",
                //       textAlign: TextAlign.center,
                //       style: GoogleFonts.poppins(
                //         color: const Color(0xFF006FFD),
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Ce week end',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'voir plus...',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF006FFD),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GFCard(
                              boxFit: BoxFit.cover,
                              image: Image.asset('your asset image'),
                              title: const GFListTile(
                                avatar: GFAvatar(
                                  backgroundImage:
                                      AssetImage('your asset image'),
                                ),
                                title: Text('Card Title'),
                                subTitle: Text('Card Sub Title'),
                              ),
                              content: const Text(
                                  "Some quick example text to build on the card"),
                              buttonBar: GFButtonBar(
                                children: <Widget>[
                                  GFButton(
                                    onPressed: () {},
                                    text: 'Buy',
                                  ),
                                  GFButton(
                                    onPressed: () {},
                                    text: 'Cancel',
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        // child: Obx(() {

        //   // if (_controller.isAuthenticated.value) {

        //     // _controller.getCompetitionList();
        //   //   return const Text('Authenticated!');
        //   // }else {
        //   //   return Column(
        //   //     children: [
        //   //       ElevatedButton(
        //   //         onPressed: () => _controller.getCompetitionList(),
        //   //         child: const Text('Authenticate'),
        //   //       ),
        //   //       Text(_controller.errorMessage.value),
        //   //     ],
        //   //   );
        //   // }
        // }),
      ),
    );
  }
}
