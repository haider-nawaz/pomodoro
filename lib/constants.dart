import 'package:flutter/material.dart';
import 'package:get/get.dart';

TextStyle titleHeading = const TextStyle(
  fontFamily: "Inter",
  fontSize: 22,
  fontWeight: FontWeight.w600,
);

TextStyle titleSubHeading = const TextStyle(
  fontFamily: "Inter",
  fontSize: 12,
  color: Colors.black,
);

const Color redColor = Color(0xffFF4C4C);

TextStyle clockStyleWhite = const TextStyle(
  fontFamily: "AlfaSlabOne",
  height: 1,
  fontSize: 100,
  color: Colors.white,
);
TextStyle clockStyle = TextStyle(
  fontFamily: "AlfaSlabOne",
  height: 1,
  fontSize: 100,
  // color: Theme.of(Get.context!).colorScheme.primary,
);
TextStyle clockStyleWhiteForText = const TextStyle(
  fontFamily: "AlfaSlabOne",
  height: 1,
  fontSize: 80,
  color: Colors.white,
);

TextStyle streakStyle = const TextStyle(
  fontFamily: "Inter",
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

TextStyle focusHeading = const TextStyle(
  fontFamily: "Inter",
  fontSize: 24,
  fontWeight: FontWeight.w600,
  // color: Colors.black,
);

String calculateFocusHoursFromMin(int min) {
  final totalFocusHours = min ~/ 60;
  final totalFocusMinutes = min % 60;

  if (totalFocusHours == 0) return "${totalFocusMinutes}m";
  return "${totalFocusHours}h ${totalFocusMinutes}m";
}
