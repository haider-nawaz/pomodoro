import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro/Views/home_view.dart';
import 'package:pomodoro/on_boarding.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'Models/focus_session.dart';
import 'Models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize("resource://drawable/logo", [
    // notification icon
    NotificationChannel(
      channelGroupKey: 'basic_test',
      channelKey: 'basic',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      channelShowBadge: true,
      importance: NotificationImportance.High,
      enableVibration: true,
    ),

    //add more notification type with different configuration
  ]);
  WakelockPlus.enable();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FocusSessionAdapter());
  final sessions = await Hive.openBox<List>('FocusSessions');
  // final List<FocusSession> sampleSessions = generateSampleFocusSessions();

  // sessions.put("sessions", sampleSessions);

  if (sessions.isEmpty) {
    //put an empty list of sessions
    await sessions.put('sessions', []);
    print("No sessions");
  } else {
    //print(sessions.get('sessions')!.length.toString());
  }
  final box = await Hive.openBox<User>('User');

  if (box.isEmpty) {
    print("No user");
    // box.put(
    //     'user',
    //     User(
    //       username: "User",
    //       firstTimeUser: true,
    //       totalPomos: 0,
    //       todaysPomos: 0,
    //       todayFocusHours: 0,
    //       netFocusHours: 0,
    //       longestStreak: 0,
    //     ));
  } else {
    print(box.get('user'));
  }

  runApp(DevicePreview(
    enabled: false,
    builder: (context) => const MyApp(),
  ));
}

List<FocusSession> generateSampleFocusSessions() {
  final List<String> sessionNames = [
    'Work',
    'Study',
    'Read',
    'Exercise',
    'Meditate',
    'Relax',
    'Sleep'
  ];
  final Random random = Random();
  final List<FocusSession> sessions = [];

  Container(
    child: Column(
      children: [
        Text("Hello"),
      ],
    ),
  );

  // Generate sessions within the last 15 days
  final DateTime now = DateTime.now();
  final DateTime fifteenDaysAgo = now.subtract(const Duration(days: 15));

  for (int i = 0; i < 10; i++) {
    final String sessionName =
        sessionNames[random.nextInt(sessionNames.length)];
    final int duration =
        random.nextInt(300); // Max duration: 12 hours (720 minutes)
    final DateTime startTime =
        fifteenDaysAgo.add(Duration(minutes: random.nextInt(15 * 24 * 60)));

    final FocusSession session = FocusSession(
      startTime: startTime.toString(),
      endTime: startTime.add(Duration(minutes: duration)).toString(),
      isFocusSessionCompleted: random.nextBool(),
      focusSessionDurationMin: duration,
      focusSessionName: sessionName,
    );

    sessions.add(session);
  }
  return sessions;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<User>('User');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Pomodoro App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: box.isEmpty ? const OnBoarding() : const HomeView(),
      //home: OnBoarding(),
    );
  }
}
