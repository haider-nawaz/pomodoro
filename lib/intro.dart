import 'package:flutter/material.dart';

import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  Color clr = const Color(0xffD9D9D9);
  List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: "Track your Focus habits with ease.",
      body: "What shoule we call you?",
      image:
          Center(child: Image.asset("assets/images/charts.png", height: 400)),
      // titleWidget: SizedBox(
      //   width: 100,
      //   child: TextField(
      //     decoration: InputDecoration(
      //       hintText: "Username",
      //       hintStyle: TextStyle(
      //         fontSize: 20,
      //         fontWeight: FontWeight.bold,
      //       ),
      //     ),
      //   ),
      // ),

      decoration: const PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 16,
          ),
          bodyAlignment: Alignment.topCenter,
          imageAlignment: Alignment.center,
          fullScreen: false,
          bodyFlex: 0),
    ),
    PageViewModel(
      title: "Select a Retailer",
      body: "See which grocer is offering the higher chashback.",
      image: Center(child: Image.asset("assets/images/charts.png")),
      // footer: ElevatedButton(
      //   onPressed: () {
      //     // On button presed
      //   },
      //   child: const Text("Let's Go !"),
      // ),
      decoration: const PageDecoration(
        bodyTextStyle: TextStyle(
          fontSize: 16,
        ),
        //bodyAlignment: Alignment.center,
        imagePadding: EdgeInsets.only(top: 100),
        //fullScreen: true,
      ),
    ),
    PageViewModel(
      title: "Upload Receipts",
      body: "Upload your receipt after every grocery shopping.",
      image: Center(child: Image.asset("assets/upload.png")),
      // footer: ElevatedButton(
      //   onPressed: () {
      //     // On button presed
      //   },
      //   child: const Text("Let's Go !"),
      // ),
      decoration: const PageDecoration(
        bodyTextStyle: TextStyle(
          fontSize: 16,
        ),
        //bodyAlignment: Alignment.center,
        imagePadding: EdgeInsets.only(top: 100),
        //fullScreen: true,
      ),
    ),
    PageViewModel(
      title: "Get Cashback",
      body: "Gift voucher or check? Both mailed to your address.",
      image: Center(child: Image.asset("assets/money.png")),
      // footer: ElevatedButton(
      //   onPressed: () {
      //     // On button presed
      //   },
      //   child: const Text("Let's Go !"),
      // ),
      decoration: const PageDecoration(
        bodyTextStyle: TextStyle(
          fontSize: 16,
        ),
        //bodyAlignment: Alignment.center,
        imagePadding: EdgeInsets.only(top: 100),
        //fullScreen: true,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: IntroductionScreen(
            pages: listPagesViewModel,
            onDone: () {
              //  AppRoutes.replace(context, const WelcomeScreen());
            },
            onSkip: () {
              // AppRoutes.replace(context, const WelcomeScreen());
            },
            onChange: (index) {
              switch (index) {
                case 0:
                  setState(() {
                    clr = const Color(0xffD9D9D9);
                  });
                  break;
                case 1:
                  setState(() {
                    clr = const Color(0xffC4B7FF);
                  });
                  break;
                case 2:
                  setState(() {
                    clr = const Color(0xff4EA3F2);
                  });
                  break;
                case 3:
                  setState(() {
                    clr = const Color(0xff7CCEAE);
                  });
                  break;
              }
            },

            showDoneButton: true,
            showBackButton: false,
            showSkipButton: true,
            showNextButton: true,
            skip: const Text(
              "Skip",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            next: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                color: Color(0xffD9D9D9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            done: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                color: Color(0xffD9D9D9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "Done",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            // done: const Text("Done",
            //     style: TextStyle(fontWeight: FontWeight.w600)),
            dotsDecorator: DotsDecorator(
                size: const Size.square(10.0),
                activeSize: const Size(20.0, 10.0),
                //activeColor: theme.accentColor,
                color: Colors.black26,
                activeColor: clr,
                spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0))),
          ),
        ),
      ),
    );
  }
}
