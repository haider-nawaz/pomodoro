import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pomodoro/Views/home_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../constants.dart';
import '../Models/focus_session.dart';
import '../Models/user.dart';

class PomoController extends GetxController {
  //analytics

  var user = Hive.box<User>('User').get('user')!;
  List<FocusSession> sessions = [];
  var focusSessions = Hive.box<List>('FocusSessions');

  Future<void> refreshUser() async {
    user = Hive.box<User>('User').get('user') ??
        User(
          username: "User",
          firstTimeUser: true,
          totalPomos: 0,
          todaysPomos: 0,
          todayFocusHours: 0,
          netFocusHours: 0,
          longestStreak: 0,
        );
    calculateFocusHours();
    print(user);
  }

  final timeTrackerMin = 0.obs;
  //a function to add a focus session to the hive box
  void addFocusSession(bool sessionCompleted, bool showSnack) async {
    final isFocusSessionCompleted =
        int.parse(currPomoTimeDup.value) == sessionMinutes.value ? true : false;

    if (isFocusSessionCompleted) {
      showStreakBadge.value = true;
    }
    print("Curr pomo time: ${currPomoTimeDup.value}");
    print("Session min: ${sessionMinutes.value}");
    final focusSession = FocusSession(
      startTime: DateTime.now().toString(),
      endTime: DateTime.now().toString(),
      focusSessionName: currFocusChip.value,
      focusSessionDurationMin: int.parse(currPomoTimeDup.value),
      isFocusSessionCompleted: isFocusSessionCompleted,
    );
    sessionMinutes.value = 0;

    print(focusSession);
    sessions.add(focusSession);
    await focusSessions.put('sessions', sessions);

    if (showSnack)
      Future.delayed(const Duration(seconds: 1), () {
        showSnackBar(sessionCompleted);
      });

    // showNotification(111, sessionCompleted? "Nice Work!":"Focus Session | ${currFocusChip.value}",
    //     "${timeTrackerMin.value} min has been logged.");
    // print(focusSessions.get('sessions'));
  }

  final showStreakBadge = false.obs;

  final streak = 0.obs;
  final sessionMinutes = 0.obs;

  final currPomoTime = "25".obs;
  final currPomoTimeDup = "25".obs;

  final animationTarget = 1.0.obs;

  final secHand = 60.obs;

  final pomoProgress = 0.0.obs;
  final focusNoteController = TextEditingController().obs;

  final currBreakTime = "0".obs;

  final chipsLoading = false.obs;
  final showTextfield = false.obs;
  final firstPomoRoundCompleted = false.obs;
  final streakStarted = false.obs;
  final keepScreenAwake = true.obs;
  final allowDND = true.obs;

  final pomoStarted = false.obs;
  final counter = 3.obs;

  String getCurrentDay() {
    var today = DateTime.now();
    var day = "";
    if (today.weekday == 1) {
      day = "Monday";
    } else if (today.weekday == 2) {
      day = "Tuesday";
    } else if (today.weekday == 3) {
      day = "Wednesday";
    } else if (today.weekday == 4) {
      day = "Thursday";
    } else if (today.weekday == 5) {
      day = "Friday";
    } else if (today.weekday == 6) {
      day = "Saturday";
    } else if (today.weekday == 7) {
      day = "Sunday";
    }
    return day;
  }

  Timer? timer;
  final enableTickSound = true.obs;

  void showNotification(int id, String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        //simgple notification
        id: id,
        channelKey: 'basic', //set configuration wuth key "basic"
        title: title,
        body: body,
      ),
    );
  }

  //a function that will update
  void updateUser() async {
    user.totalPomos++;
    user.todaysPomos++;
    user.todayFocusHours += int.parse(currPomoTimeDup.value);
    user.netFocusHours += int.parse(currPomoTimeDup.value);
    if (user.longestStreak < streak.value) {
      user.longestStreak = streak.value;
    }
    await Hive.box<User>('User').put('user', user);
  }

  void loadSessions() {
    //loop through the sessions and add them to the sessions list
    for (final session in focusSessions.get("sessions")!) {
      sessions.add(
        FocusSession(
          startTime: session.startTime,
          endTime: session.endTime,
          focusSessionName: session.focusSessionName,
          focusSessionDurationMin: session.focusSessionDurationMin,
          isFocusSessionCompleted: session.isFocusSessionCompleted,
        ),
      );
    }

    print("Sessions ${sessions.length}");
    analyzeSessions();
  }

  //a function to calculate the total focus hours from miuntes
  void calculateFocusHours() {
    final totalFocusHours = user.netFocusHours ~/ 60;
    final totalFocusMinutes = user.netFocusHours % 60;
    print("$totalFocusHours h $totalFocusMinutes m");
  }

  final pomoTimesList = <String>[
    "2",
    "15",
    "20",
    "25",
    "30",
    "35",
    "40",
    "45",
    "50",
    "55",
    "60"
  ].obs;

  //a list of focus chips that will hold the text and icon and a color for each chip
  final focusChipsTexts = <String, List>{
    "Work": [CupertinoIcons.device_laptop, Colors.red],
    "Study": [Icons.school, Colors.blue],
    "Read": [Icons.menu_book, Colors.green],
    "Exercise": [Icons.fitness_center, Colors.orange],
    "Meditate": [Icons.self_improvement, Colors.purple],
    "Relax": [Icons.spa, Colors.pink],
    "Sleep": [Icons.nightlight_round, Colors.indigo],
  };

  final currFocusChip = "Work".obs;

  final audioPlayer = AudioPlayer();

  @override
  void onInit() {
    //open the user box

    sessionMinutes.value = 0;
    focusNoteController.value.text = "Don't you Quit!";
    chipsLoading.value = true;

    loadSessions();

    super.onInit();
  }

  Widget buildFocusChips() {
    // a list of chips with icons from focusChipsTexts
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: focusChipsTexts.entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: GestureDetector(
                onTap: () {
                  currFocusChip.value = e.key;
                  Get.back();
                },
                child: Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      height: 50,
                      //width: Get.size.width,
                      width: Get.size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!)
                            .colorScheme
                            .secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                        // border: currFocusChip.value == e.key
                        //     ? Border.all(
                        //         color: e.value[1],
                        //         width: 1,
                        //       )
                        //     : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              e.value[0],
                              color: Theme.of(Get.context!)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(Get.context!)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              currFocusChip.value == e.key
                                  ? Icons.check
                                  : Icons.arrow_forward_ios,
                              color: Theme.of(Get.context!)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget buildPomoChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pomoTimesList
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () async {
                    //play haptic feedback

                    await HapticFeedback.selectionClick();
                    currPomoTime.value = e;
                    currPomoTimeDup.value = e;
                    animationTarget.value = 1.0;
                  },
                  child: Obx(
                    () => Chip(
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),

                        // side: BorderSide.none,
                      ),
                      label: Text(
                        "$e min",
                      ),
                      backgroundColor: currPomoTime.value == e
                          ? Theme.of(Get.context!)
                              .colorScheme
                              .secondaryContainer
                          : null,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void startPomo(bool isResume) {
    print("Pomo Started");
    if (streakStarted.value) {
      currPomoTime.value = currPomoTimeDup.value;
      secHand.value = 60;

      print("currPomoTimeDup: ${currPomoTimeDup.value}");
      print("currPomoTime: ${currPomoTime.value}");
    }

    playTickSound();
    if (isResume) {
      print("curr pomo time ${currPomoTime.value}");
      currPomoTime.value = currPomoTimeDup.value;
      final totalPomoTime =
          (int.parse(currPomoTime.value) * 60 + secHand.value) -
              (sessionMinutes.value * 60);
      print("Rem time: $totalPomoTime s");
    }
    final totalPomoTime =
        int.parse(currPomoTime.value) * 60; // Convert minutes to seconds

    //decrement the currPomoTime (min hand) by 1 initialy
    currPomoTime.value = (int.parse(currPomoTime.value) - 1).toString();

    //after every 60 sec decrement the currPomoTime and after every 1 sec decrement the secHand
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secHand.value == 0) {
        timeTrackerMin.value++;
        sessionMinutes.value = sessionMinutes.value + 1;
        print("Session min: ${sessionMinutes.value}");

        secHand.value = 60;
        currPomoTime.value = (int.parse(currPomoTime.value) - 1).toString();
      }
      secHand.value = secHand.value - 1;
      // Calculate pomoProgress
      final remainingTime = int.parse(currPomoTime.value) * 60 + secHand.value;
      pomoProgress.value = 1 - (remainingTime / totalPomoTime);

      print("Pomo Progress: ${pomoProgress.value}");

      //it will be everytime true whenever the pomo is completed
      if (currPomoTime.value == "0" && secHand.value == 0) {
        streak.value++;
        updateUser();
        addFocusSession(false, true);

        streakStarted.value = true;

        currPomoTime.value = currPomoTimeDup.value;
        //Future.delayed(const Duration(seconds: 2), () {});
      }
    });
  }

  void startBreak() {
    print("Break Started");
  }

  void stopBreak() {
    print("Break Stopped");
  }

  void resetPomo() {
    currPomoTime.value = "25";
    currPomoTimeDup.value = "25";
    secHand.value = 60;
    pomoProgress.value = 0.0;
    counter.value = 3;
    streak.value = 0;
    sessionMinutes.value = 0;
    timeTrackerMin.value = 0;
    streakStarted.value = false;

    print("Pomo Reset");
  }

  void endPomo(bool forceClose) {
    //only show snackbar if the session is completed
    if (timeTrackerMin.value >= int.parse(currPomoTimeDup.value)) {
      addFocusSession(true, true);
    } else {
      addFocusSession(false, false);
    }

    stopTickSound();
    timer?.cancel();

    resetPomo();
    pomoStarted.value = false;
    if (!forceClose) {
      Get.back();
      Get.off(
        () => const HomeView(),
        transition: Transition.downToUp,
      );
    }

    print("Pomo Ended");
  }

  Future<void> playTickSound() async {
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.setSource(AssetSource('sounds/tick.mp3'));
    await audioPlayer.resume();
  }

  void stopTickSound() async {
    await audioPlayer.stop();
  }

  void toggleVolume() {
    enableTickSound.value = !enableTickSound.value;
    if (enableTickSound.value) {
      playTickSound();
    } else {
      stopTickSound();
    }
  }

  void toggleKeepScreenAwake() {
    keepScreenAwake.value = !keepScreenAwake.value;
    WakelockPlus.toggle(enable: keepScreenAwake.value).then((value) {
      Get.showSnackbar(
        GetSnackBar(
          message: keepScreenAwake.value
              ? "Screen will be kept awake."
              : "Screen will not be kept awake.",
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          // backgroundColor: Colors.blue.withOpacity(.5),
          borderColor: Colors.black,
        ),
      );
    });
  }

  void setInterruptionFilter(int filter) async {
    final bool? isNotificationPolicyAccessGranted =
        await FlutterDnd.isNotificationPolicyAccessGranted;
    if (isNotificationPolicyAccessGranted != null &&
        isNotificationPolicyAccessGranted) {
      await FlutterDnd.setInterruptionFilter(filter);
    }
  }

  void toggleDND() async {
    allowDND.value = !allowDND.value;
    if ((await FlutterDnd.isNotificationPolicyAccessGranted) == true) {
      if (allowDND.value) {
        setInterruptionFilter(FlutterDnd
            .INTERRUPTION_FILTER_PRIORITY); // Turn on DND - All notifications are suppressed.
      } else {
        setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
      }

      Get.showSnackbar(
        GetSnackBar(
          message: allowDND.value
              ? "All notifications are suppressed. You will not be disturbed during your session."
              : "You've allowed notifications.",
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          // backgroundColor: Colors.blue.withOpacity(.5),
          borderColor: Colors.black,
        ),
      );
    } else {
      FlutterDnd.gotoPolicySettings();
    }
  }

  void showSnackBar(bool sessionCompleted) {
    Get.showSnackbar(
      GetSnackBar(
        title: sessionCompleted
            ? "Congrats! on completing a session"
            : "Focus Session Update",
        message: sessionCompleted
            ? "Hope on to Analytics center to see how you're doing."
            : "${calculateFocusHoursFromMin(timeTrackerMin.value)} logged in your ${currFocusChip.value} session.",
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        // backgroundColor: Colors.blue.withOpacity(.5),
        borderColor: Colors.black,
      ),
    );
  }

  var todaysSessionsNum = 0;
  var todaysFocusMin = 0;
  var netFocusMin = 0;
  var dailyAverageFocusMinByWeek = 0;

  var focusMinByChips = <String, int>{};

  var focusMinByDay = <String, int>{
    "Mn": 0,
    "Tu": 0,
    "Wd": 0,
    "Th": 0,
    "Fr": 0,
    "St": 0,
    "Sn": 0,
  };

  var sessionsByChip = <String, int>{};

  //analytics functions

  void analyzeSessions() {
    //initialize the focusMinByChips map
    focusChipsTexts.forEach((key, value) {
      focusMinByChips.putIfAbsent(key, () => 0);
      sessionsByChip.putIfAbsent(key, () => 0);
    });

    var today = DateTime.now();

    //covert string to DateTime

    //loop through all sessions and calculate
    for (var session in sessions) {
      //for every session in the last 24 hours
      if (DateTime.parse(session.startTime!)
          .isAfter(today.subtract(const Duration(hours: 24)))) {
        todaysSessionsNum++;
        todaysFocusMin += session.focusSessionDurationMin!;
      }

      netFocusMin += session.focusSessionDurationMin!;

      //calculate the focus minutes by chips
      focusMinByChips[session.focusSessionName!] =
          focusMinByChips[session.focusSessionName!]! +
              session.focusSessionDurationMin!;

      //calculate the sessions by chips
      sessionsByChip[session.focusSessionName!] =
          sessionsByChip[session.focusSessionName!]! + 1;

      //calculate the focus minutes by day
      if (DateTime.parse(session.startTime!).weekday == 1) {
        focusMinByDay["Mn"] =
            focusMinByDay["Mn"]! + session.focusSessionDurationMin!;
      } else if (DateTime.parse(session.startTime!).weekday == 2) {
        focusMinByDay["Tu"] =
            focusMinByDay["Tu"]! + session.focusSessionDurationMin!;
      } else if (DateTime.parse(session.startTime!).weekday == 3) {
        focusMinByDay["Wd"] =
            focusMinByDay["Wd"]! + session.focusSessionDurationMin!;
      } else if (DateTime.parse(session.startTime!).weekday == 4) {
        focusMinByDay["Th"] =
            focusMinByDay["Th"]! + session.focusSessionDurationMin!;
      } else if (DateTime.parse(session.startTime!).weekday == 5) {
        focusMinByDay["Fr"] =
            focusMinByDay["Fr"]! + session.focusSessionDurationMin!;
      } else if (DateTime.parse(session.startTime!).weekday == 6) {
        focusMinByDay["St"] =
            focusMinByDay["St"]! + session.focusSessionDurationMin!;
      } else if (DateTime.parse(session.startTime!).weekday == 7) {
        focusMinByDay["Sn"] =
            focusMinByDay["Sn"]! + session.focusSessionDurationMin!;
      }
    }

    print("Todays Sessions: $todaysSessionsNum");
    print("Todays Focus Min: $todaysFocusMin");
    print("Net Focus Min: $netFocusMin");

    print(focusMinByChips);
    print(focusMinByDay);
    print(sessionsByChip);
  }

  int calculateDailyAvg() {
    //avg of last 7 days

    dailyAverageFocusMinByWeek =
        focusMinByDay.values.reduce((a, b) => a + b) ~/ 7;
    print("Daily Avg: $dailyAverageFocusMinByWeek");
    return dailyAverageFocusMinByWeek;
  }

  void pauseSession() {
    stopTickSound();
    timer?.cancel();
  }

  void resumeSession() {
    print("Resuming session..");
    // Future.delayed(const Duration(seconds: 1), () {
    startPomo(true);
    //});
  }
}
