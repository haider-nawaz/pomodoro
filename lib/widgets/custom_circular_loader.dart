import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:pomodoro/Controllers/pomo_controller.dart';
import 'package:pomodoro/constants.dart';

class CustomPomoWidget extends StatefulWidget {
  final String time;
  final bool isCounter;
  final double animationTarget;
  const CustomPomoWidget(
      {super.key,
      required this.time,
      required this.isCounter,
      required this.animationTarget});

  @override
  State<CustomPomoWidget> createState() => _CustomPomoWidgetState();
}

class _CustomPomoWidgetState extends State<CustomPomoWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: CircleProgressBar(
        foregroundColor: Colors.blue,
        backgroundColor: Colors.black12,
        value: 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.time.length == 1 ? "0${widget.time}" : widget.time,
                style: clockStyle,
              ).animate().scale(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
              if (!widget.isCounter)
                Text(
                  // textHeightBehavior: const TextHeightBehavior(
                  //   applyHeightToFirstAscent: false,
                  //   applyHeightToLastDescent: false,
                  // ),
                  "00",
                  style: clockStyle,
                )
                    .animate(
                        //target: widget.animationTarget,
                        //onComplete: (controller) => controller.repeat(),
                        )
                    .scale(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
