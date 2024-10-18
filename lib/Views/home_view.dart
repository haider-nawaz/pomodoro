import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pomodoro/Views/analytics_view.dart';
import 'package:pomodoro/Views/pomo_view.dart';
import 'package:pomodoro/constants.dart';
import 'package:pomodoro/widgets/custom_circular_loader.dart';
import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';

import '../Controllers/pomo_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Color greenColor = Theme.of(Get.context!).colorScheme.secondary;
  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => askNotiPermision(context));
    WidgetsBinding.instance.addPostFrameCallback((_) => askDNDPermission());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();
    final pomoController = Get.put(PomoController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(
        () => pomoController.pomoStarted.value
            ? counterWidget(context, pomoController)
                .animate()
                .slideY(
                    // duration: const Duration(milliseconds: 500),
                    //delay: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut)
                .fadeIn()
            : SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          child: headerWidget(pomoController),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        focusTimesWidget(context, pomoController),
                        const SizedBox(
                          height: 50,
                        ),
                        focusChipWidget(context, pomoController),
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(
                          () => CustomPomoWidget(
                            time: pomoController.currPomoTime.value,
                            isCounter: false,
                            animationTarget:
                                pomoController.animationTarget.value,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        playBtnWidget(pomoController),
                        SizedBox(
                          height: Get.size.height * .08,
                        ),
                        focusTextWidget(context, focusNode, pomoController),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Row headerWidget(PomoController pomoController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 12,
            ),
            Text(
              "hi ${pomoController.user.username} 👋",
              style: const TextStyle(
                fontFamily: "Inter",
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ).animate().fadeIn().moveX(),
            // Text(
            //   // text:
            //   "It's ${pomoController.getCurrentDay()}, ready to get some work done?",
            //   style: const TextStyle(
            //     fontFamily: "Inter",
            //     fontSize: 14,
            //     color: Colors.black54,
            //     fontWeight: FontWeight.normal,
            //   ),
            // ),
          ],
        ),
        //const Spacer(),
        GestureDetector(
          onTap: () {
            Get.to(
              curve: Curves.easeIn,
              transition: Transition.fadeIn,
              () => const AnalyticsView(),
            );
          },
          child: Stack(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).highlightColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pomoController.user.longestStreak.toString(),
                      style: const TextStyle(
                        // color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.flame_fill,
                      color: Theme.of(Get.context!).colorScheme.secondary,
                      size: 15,
                    ),
                  ],
                ),
              ),
              if (pomoController.showStreakBadge.value)
                const Positioned(
                  right: 5,
                  child:
                      Icon(Icons.circle_rounded, color: Colors.red, size: 10),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Row focusTimesWidget(BuildContext context, PomoController pomoController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // const Icon(Icons.arrow_back_ios_rounded),
        Expanded(
          // width: MediaQuery.of(context).size.width * .99,
          child: pomoController.buildPomoChips(),
        ),
        // const Icon(Icons.arrow_forward_ios_rounded),
      ],
    );
  }

  GestureDetector playBtnWidget(PomoController pomoController) {
    return GestureDetector(
      onTap: () async {
        //wait for 500ms
        //Future.delayed(const Duration(seconds: 1), () async {
        final audioPlayer = AudioPlayer();
        await audioPlayer.setReleaseMode(ReleaseMode.loop);
        await audioPlayer.setSource(AssetSource('sounds/bleep.wav'));
        pomoController.pomoStarted.value = true;

        Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (pomoController.counter.value == 0) {
            timer.cancel();
            await audioPlayer.stop();
            await audioPlayer.dispose();

            //pomoController.pomoStarted.value = false;
            Get.off(
                //curve: Curves.easeIn,
                transition: Transition.downToUp,
                () => const PomoView());
          } else {
            await audioPlayer.resume();

            pomoController.counter.value--;
          }
        });
        // });
      },
      child: Container(
        height: 65,
        width: 140,
        decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: greenColor.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ]),
        child: const Center(
          child: Icon(
            Icons.play_arrow_rounded,
            // color: Colors.white,
            size: 60,
          ),
        ),
      ),
    );
  }

  GestureDetector focusChipWidget(
      BuildContext context, PomoController pomoController) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            //fullscreenDialog: false,
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  Container(
                    height: Get.size.height * 0.7,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Focus Chips",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  "Select a focus chip to start a pomo session.",
                                  // style: focusHeading,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 20,
                        ),
                        pomoController.buildFocusChips(),
                      ],
                    ),
                  ),
                ],
              );
            });
      },
      child: Container(
        height: 40,
        width: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(50),
          // border: Border.all(
          //   color: Colors.black,
          //   width: 1,
          // ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    pomoController.focusChipsTexts[
                        pomoController.currFocusChip.value]![0],
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    pomoController.currFocusChip.value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector focusTextWidget(BuildContext context, FocusNode focusNode,
      PomoController pomoController) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              // FocusScope.of(context).requestFocus(focusNode);

              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Focus Note",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              "Type something that'll keep you motivated.",
                              // style: focusHeading,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextFormField(
                            maxLength: 20,
                            style: const TextStyle(fontSize: 20),
                            controller:
                                pomoController.focusNoteController.value,
                            autofocus: true,
                            decoration: InputDecoration(
                              // prefixIcon: const Icon(
                              //   Icons.bolt,
                              //   // color: Colors.grey,
                              // ),

                              //border: OutlineInputBorder(),
                              //fillColor: Colors.white,
                              filled: false,
                              //labelStyle: const TextStyle(color: Colors.black45),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35.0),
                                borderSide: const BorderSide(
                                    //color: Colors.black45,
                                    ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35.0),
                                borderSide: const BorderSide(
                                    // color: Colors.black45,
                                    ),
                              ),
                            ),
                            focusNode: focusNode,
                            onFieldSubmitted: (value) {
                              pomoController.focusNoteController.value.text =
                                  value;
                            },
                            onChanged: (value) {
                              pomoController.focusNoteController.value.text =
                                  value;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Get.back();
                              setState(() {});
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(50),
                                // border: Border.all(
                                //   color: Colors.black,
                                //   width: 1,
                                // ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "If you dont want to add a note, just leave it blank.",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              );
            });
      },
      child: Container(
        // duration: const Duration(
        //   milliseconds: 1000,
        // ),
        height: Get.size.height * 0.09,
        width: 210,
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).highlightColor,
          borderRadius: BorderRadius.circular(50),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(.5),
          //     blurRadius: 10,
          //     offset: const Offset(0, 0),
          //   ),
          // ],
          // border: Border.all(
          //   color: Colors.black,
          //   width: 1,
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => Text(
                  pomoController.focusNoteController.value.text.toString(),
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 18,
                    // color:
                    //     Theme.of(Get.context!).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Icon(
                Icons.edit,
                // color: Theme.of(Get.context!).colorScheme.onSecondaryContainer,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container counterWidget(BuildContext context, PomoController pomoController) {
    return Container(
      color: greenColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Obx(
          () => SizedBox(
            height: 300,
            width: 300,
            child: CircleProgressBar(
              foregroundColor: Colors.white,
              // backgroundColor: Colors.white,
              //reversedDirection: true,
              strokeWidth: 12,
              value: pomoController.counter.value.toDouble() / 3.toDouble(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pomoController.counter.value.toString(),
                      style: clockStyleWhite,
                    )
                        .animate(
                          onComplete: (controller) {
                            controller.loop(count: 3);
                          },
                        )
                        .scale(
                          duration: const Duration(
                            milliseconds: 1000,
                          ),
                          curve: Curves.easeInOut,
                          //curve: Curves.easeInOut,
                        )
                        .then(delay: const Duration(milliseconds: 00)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget widgets(int flex, Widget child) {
    return Flexible(
      flex: flex,
      child: Container(
        //make it a circle
        // width: 90,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xffD9D9D9).withOpacity(1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: child,
        ),
      ),
    );
  }

  askNotiPermision(BuildContext context) async {
    //show a bottom sheet with some text and button
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Material(
                  child: SizedBox(
                height: 320,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Notifications",
                                style: focusHeading,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "We'll send you important notifications on your on-going sessions and your progress over time.",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 14,
                                  // color: Colors.black54,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await AwesomeNotifications()
                                    .requestPermissionToSendNotifications();
                                Get.back();
                              },
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(.5),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    // color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Allow",
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.pink.withOpacity(.8),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    // color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Don't Allow",
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            });
      }
    });
  }

  void askDNDPermission() async {
    var status = await Permission.accessNotificationPolicy.status;
    print(status);
    if (!status.isGranted)
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Material(
                child: SizedBox(
              height: 320,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Do Not Disturb ",
                              style: focusHeading,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "We'll automatically turn on Do Not Disturb mode during your sessions to help you focus. You can always toggle this during a session.",
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 14,
                                // color: Colors.black54,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              FlutterDnd.gotoPolicySettings();
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  // color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Allow",
                                  style: TextStyle(
                                    // color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text("This will take you to your phone's settings."),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
          });
  }
}
