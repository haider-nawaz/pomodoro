import 'package:animate_gradient/animate_gradient.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro/constants.dart';

import 'Models/user.dart';
import 'Views/home_view.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final nameController = TextEditingController();

  onDone() {
    Hive.box<User>('User').put(
      'user',
      User(
        username: "there",
        firstTimeUser: false,
        totalPomos: 0,
        todaysPomos: 0,
        longestStreak: 0,
        netFocusHours: 0,
        todayFocusHours: 0,
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.offAll(
        () => const HomeView(),
        transition: Transition.fade,
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: AnimateGradient(
        primaryBegin: Alignment.bottomCenter,
        primaryEnd: Alignment.topCenter,
        secondaryBegin: Alignment.topCenter,
        secondaryEnd: Alignment.bottomCenter,
        animateAlignments: false,
        primaryColors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.inversePrimary,
        ],
        secondaryColors: [
          Theme.of(context).colorScheme.secondary,
          Theme.of(context).colorScheme.secondaryContainer,
        ],
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 40,
              ),
              Column(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text(
                  //   "No B.S.",
                  //   style: TextStyle(
                  //     height: 1.3,
                  //     fontSize: 12,
                  //     fontFamily: 'Inter',
                  //     color: Colors.white.withOpacity(1),
                  //   ),
                  // ),
                  Text(
                    "Pomodoro",
                    style: titleHeading.copyWith(
                      fontSize: 30,
                      // color: Colors.white.withOpacity(1),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 350,
                    child: Text(
                      'A simple & no B.S. time management app that uses a timer to break down your work into short intervals',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.3,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        // color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),

                  //a transparent button
                ],
              ),
              Container(
                width: 200,
                height: 50,
                margin: const EdgeInsets.only(bottom: 15),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.black.withOpacity(.1)),
                  ),
                  onPressed: () async {
                    await HapticFeedback.heavyImpact();
                    onDone();
                  },
                  child: Text(
                    "Let's Go",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }

  OnBoardingSlider customOnBoardSlider(BuildContext context) {
    return OnBoardingSlider(
      controllerColor: Colors.black,

      addController: false,
      indicatorPosition: 0,
      //pageBackgroundColor: Colors.white,
      headerBackgroundColor: Colors.transparent,
      finishButtonText: 'Let\'s Go !',
      indicatorAbove: false,

      finishButtonTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),

      finishButtonStyle: FinishButtonStyle(
        backgroundColor:
            !(nameController.text.length >= 3) ? Colors.black : Colors.black,
      ),
      onFinish: onDone,
      //skipTextButton: const Text('Skip'),
      trailing: const Row(
        children: [
          Spacer(),
          Text(
            'One more thing...',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.black54,
              fontSize: 14,
              //fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
        ],
      ),
      centerBackground: true,
      // imageVerticalOffset: 70,
      //imageHorizontalOffset: 0,
      background: [
        Image.asset('assets/images/work.png', height: Get.size.height * 0.35),
        Image.asset('assets/images/Graph.png', height: Get.size.height * 0.4),
        // Image.asset('assets/images/noti.png', height: Get.size.height * 0),
        // Image.asset('assets/images/dnd.png', height: Get.size.height * 0),
        Image.asset('assets/images/person.png', height: Get.size.height * 0.25),
      ],
      totalPage: 3,
      speed: 1.5,
      pageBodies: [
        Container(
          //color: Colors.white,
          //alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Take control of your time with Pomodoro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.2,
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Pomodoro is a time management technique that uses a timer to break down work into intervals. ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.3,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  color: Colors.black54,
                ),
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
        Container(
          //color: Colors.white,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Track how you spend your time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.2,
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'With utility based metrics, analyze your habits and live a more productive life.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.3,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  color: Colors.black54,
                ),
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
        // Container(
        //   //color: Colors.white,
        //   alignment: Alignment.center,
        //   width: MediaQuery.of(context).size.width,
        //   padding: const EdgeInsets.symmetric(horizontal: 40),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: <Widget>[
        //       Text(
        //         'Get updates on your on-going sessions.',
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           height: 1.2,
        //           fontFamily: 'Inter',
        //           fontSize: 28,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       SizedBox(
        //         height: 20,
        //       ),
        //       ElevatedButton(
        //         style: ButtonStyle(
        //           backgroundColor: MaterialStateProperty.all(
        //             Color(0xff407BFF),
        //           ),
        //         ),
        //         onPressed: () async {
        //           bool isallowed =
        //               await AwesomeNotifications().isNotificationAllowed();
        //           if (!isallowed) {
        //             await AwesomeNotifications()
        //                 .requestPermissionToSendNotifications();
        //           } else {
        //             print("Already allowed");
        //           }
        //           //no permission of local notification
        //         },
        //         child: Text(
        //           "Allow Notifications",
        //           style: TextStyle(
        //             fontFamily: 'Inter',
        //             fontSize: 16,
        //             fontWeight: FontWeight.w500,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        //       Text(
        //         'Focus without distractions.',
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           height: 1.2,
        //           fontFamily: 'Inter',
        //           fontSize: 28,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       SizedBox(
        //         height: 20,
        //       ),
        //       ElevatedButton(
        //         style: ButtonStyle(
        //           backgroundColor: MaterialStateProperty.all(
        //             Color(0xff407BFF),
        //           ),
        //         ),
        //         onPressed: () {
        //           FlutterDnd.gotoPolicySettings();
        //           //no permission of local notification
        //         },
        //         child: Text(
        //           "Allow Do Not Disturb",
        //           style: TextStyle(
        //             fontFamily: 'Inter',
        //             fontSize: 16,
        //             fontWeight: FontWeight.w500,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        //       SizedBox(
        //         height: 10,
        //       ),
        //       Text(
        //         'You can always change this during session.',
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           height: 1.2,
        //           fontFamily: 'Inter',
        //           fontSize: 16,
        //           color: Colors.black54,
        //           //fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       SizedBox(
        //         height: 100,
        //       ),
        //     ],
        //   ),
        // ),
        // Container(
        //   //color: Colors.white,
        //   alignment: Alignment.center,
        //   width: MediaQuery.of(context).size.width,
        //   padding: const EdgeInsets.symmetric(horizontal: 40),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: <Widget>[
        //       Text(
        //         'Focus without distractions.',
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           height: 1.2,
        //           fontFamily: 'Inter',
        //           fontSize: 28,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       SizedBox(
        //         height: 20,
        //       ),
        //       ElevatedButton(
        //         style: ButtonStyle(
        //           backgroundColor: MaterialStateProperty.all(
        //             Color(0xff407BFF),
        //           ),
        //         ),
        //         onPressed: () {
        //           FlutterDnd.gotoPolicySettings();
        //           //no permission of local notification
        //         },
        //         child: Text(
        //           "Allow Do Not Disturb",
        //           style: TextStyle(
        //             fontFamily: 'Inter',
        //             fontSize: 16,
        //             fontWeight: FontWeight.w500,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        //       SizedBox(
        //         height: 10,
        //       ),
        //       Text(
        //         'You can always change this during session.',
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           height: 1.2,
        //           fontFamily: 'Inter',
        //           fontSize: 16,
        //           color: Colors.black54,
        //           //fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       SizedBox(
        //         height: Get.size.height * 0.1,
        //       ),
        //     ],
        //   ),
        // ),
        Container(
          /// color: Colors.red,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "What should we call you?",
                    style: TextStyle(
                      //height: 1.2,
                      fontFamily: 'Inter',
                      fontSize: 24,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {});
                      },

                      onFieldSubmitted: (value) {
                        nameController.text = value.toString();
                        onDone();
                      },
                      enableSuggestions: false,
                      autocorrect: false,
                      //onEditingComplete: ,
                      controller: nameController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      maxLength: 8,
                      cursorColor: Colors.black,
                      //cursorHeight: 27,

                      style: const TextStyle(
                        //height: 2,
                        fontFamily: 'Inter',
                        fontSize: 26,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        // enabledBorder: UnderlineInputBorder(
                        //   borderSide: BorderSide(
                        //     color: Colors.black45,
                        //   ),
                        // ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black45,
                          ),
                        ),
                        hintText: '',
                        hintStyle: TextStyle(
                          // height: 2,
                          fontFamily: 'Inter',
                          fontSize: 26,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeIn,
                  ),
              const SizedBox(
                height: 30,
              ),
              // const Text(
              //   'You can always change this later.',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     height: 1.3,
              //     fontSize: 14,
              //     fontFamily: 'Inter',
              //     color: Colors.black54,
              //   ),
              // ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
