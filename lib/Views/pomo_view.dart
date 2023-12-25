import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import '../Controllers/pomo_controller.dart';
import '../constants.dart';

class PomoView extends StatefulWidget {
  const PomoView({super.key});

  @override
  State<PomoView> createState() => _PomoViewState();
}

class _PomoViewState extends State<PomoView> with WidgetsBindingObserver {
  //if the app is closed, end the pomo session and save the data
  @override
  void initState() {
    pomoController
        .setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_PRIORITY);
    pomoController.startPomo(false);
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    print("disposed");
    WidgetsBinding.instance.removeObserver(this);
    pomoController.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);

    super.dispose();
  }

  final pomoController = Get.find<PomoController>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //           .isNotificationAllowed();
    if (state == AppLifecycleState.paused) {
      //if (isNotificationAllowed) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          //simgple notification
          id: 123,
          channelKey: 'basic', //set configuration wuth key "basic"
          title: 'Focus Session Update',
          body: 'Your focus session has been paused. Go back to continue!',
        ),
      );
      // }

      print("paused");
      pomoController.pauseSession();
    } else if (state == AppLifecycleState.resumed) {
      print("resumed");
      Future.delayed(const Duration(seconds: 2), () {
        pomoController.resumeSession();
      });
    } else if (state == AppLifecycleState.detached) {
      print("detached");
      pomoController.endPomo(false);
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            pomoController.toggleVolume();
                          },
                          icon: pomoController.enableTickSound.value
                              ? const Icon(CupertinoIcons.volume_up)
                              : const Icon(
                                  CupertinoIcons.volume_mute,
                                  color: Colors.red,
                                ),
                        ),
                        IconButton(
                          onPressed: () {
                            pomoController.toggleDND();
                          },
                          icon: !pomoController.allowDND.value
                              ? const Icon(CupertinoIcons.bell_fill)
                              : const Icon(
                                  CupertinoIcons.bell_slash_fill,
                                  color: Colors.red,
                                ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              if (pomoController.focusNoteController.value.text.isNotEmpty)
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  color: const Color(0xffD9D9D9),
                  child: Marquee(
                    text: pomoController.focusNoteController.value.text
                        .toString(),
                    style: const TextStyle(
                      fontFamily: "Inter",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 10.0,
                    velocity: 100.0,
                    //pauseAfterRound: const Duration(seconds: 1),
                  ),
                ),
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  color: pomoController
                      .focusChipsTexts[pomoController.currFocusChip.value]![1]
                      .withOpacity(.1),
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
                            color: pomoController.focusChipsTexts[
                                pomoController.currFocusChip.value]![1],
                            size: 20,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            pomoController.currFocusChip.value,
                            style: TextStyle(
                              color: pomoController.focusChipsTexts[
                                  pomoController.currFocusChip.value]![1],
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
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  pomoWidget(pomoController),
                  const SizedBox(
                    height: 10,
                  ),
                  //streak widget
                  Obx(
                    () => pomoController.streakStarted.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("x${pomoController.streak.value}",
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      )),
                                  Icon(
                                    CupertinoIcons.flame_fill,
                                    color: Colors.orange,
                                  )
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.black,
                                  size: 5,
                                ),
                              ),
                              Center(
                                child: Text(
                                  calculateFocusHoursFromMin(
                                      pomoController.timeTrackerMin.value),
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(
                    () => pomoController.firstPomoRoundCompleted.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  pomoController.endPomo(false);
                                },
                                child: Container(
                                  height: 55,
                                  width: 130,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: redColor,
                                      )),
                                  child: const Center(
                                    child: Text(
                                      "QUIT",
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: redColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  pomoController.streakStarted.value = true;
                                  pomoController.pomoProgress.value = 0;
                                  pomoController.startPomo(false);
                                },
                                child: pomoController.streakStarted.value
                                    ? const SizedBox()
                                    : Container(
                                        height: 65,
                                        width: 140,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFF5E0E),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Bring it On!",
                                            style: TextStyle(
                                              fontFamily: "Inter",
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text(
                                      "Are you sure you want to quit?"),
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  content: Text(
                                      "You have completed ${pomoController.sessionMinutes.value} minutes of your Focus Session."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),

                                        //giver border color of red

                                        side: MaterialStateProperty.all(
                                          const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        pomoController.endPomo(false);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red),
                                      ),
                                      child: const Text("Quit",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              height: 65,
                              width: 140,
                              decoration: BoxDecoration(
                                color: redColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Center(
                                child: Text(
                                  "End",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox pomoWidget(PomoController pomoController) {
    return SizedBox(
      height: 300,
      width: 300,
      child: Obx(
        () => CircleProgressBar(
          foregroundColor: greenColor,
          backgroundColor: const Color(0xffD9D9D9),

          //the stroke width would depend on the number of streaks
          //if streak is 0, then stroke width is default and would increase by 1 for every 1 streak

          strokeWidth: 7,
          value: pomoController.pomoProgress.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pomoController.currPomoTime.value.toString().length == 1
                      ? "0${pomoController.currPomoTime.value}"
                      : pomoController.currPomoTime.value.toString(),
                  style: clockStyle,
                ),
                Text(
                  pomoController.secHand.value.toString().length == 1
                      ? "0${pomoController.secHand.value}"
                      : pomoController.secHand.value.toString(),
                  style: clockStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
