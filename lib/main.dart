import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:dynamic_color/dynamic_color.dart';
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
  AwesomeNotifications().initialize(null, [
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

bool _isDemoUsingDynamicColors = false;
CustomColors lightCustomColors = const CustomColors(danger: Color(0xFFE53935));
CustomColors darkCustomColors = const CustomColors(danger: Color(0xFFEF9A9A));

// Fictitious brand color.
const _brandBlue = Color(0xFF1E88E5);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<User>('User');
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        // On Android S+ devices, use the provided dynamic color scheme.
        // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
        lightColorScheme = lightDynamic.harmonized();
        // (Optional) Customize the scheme as desired. For example, one might
        // want to use a brand color to override the dynamic [ColorScheme.secondary].
        lightColorScheme = lightColorScheme.copyWith(secondary: _brandBlue);
        // (Optional) If applicable, harmonize custom colors.
        lightCustomColors = lightCustomColors.harmonized(lightColorScheme);

        // Repeat for the dark color scheme.
        darkColorScheme = darkDynamic.harmonized();
        darkColorScheme = darkColorScheme.copyWith(secondary: _brandBlue);
        darkCustomColors = darkCustomColors.harmonized(darkColorScheme);

        _isDemoUsingDynamicColors = true; // ignore, only for demo purposes
      } else {
        // Otherwise, use fallback schemes.
        lightColorScheme = ColorScheme.fromSeed(
          seedColor: _brandBlue,
        );
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: _brandBlue,
          brightness: Brightness.dark,
        );
      }
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'Pomodoro App',
        theme: ThemeData(
          colorScheme: lightDynamic ?? lightColorScheme,
        ),
        darkTheme: ThemeData(
          colorScheme: darkDynamic ?? darkColorScheme,
          brightness: Brightness.dark,
        ),
        home: box.isEmpty ? const OnBoarding() : const OnBoarding(),

        //home: OnBoarding(),
      );
    });
  }
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.danger,
  });

  final Color? danger;

  @override
  CustomColors copyWith({Color? danger}) {
    return CustomColors(
      danger: danger ?? this.danger,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      danger: Color.lerp(danger, other.danger, t),
    );
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(danger: danger!.harmonizeWith(dynamic.primary));
  }
}
