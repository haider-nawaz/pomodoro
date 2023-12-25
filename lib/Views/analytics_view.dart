import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../Controllers/pomo_controller.dart';
import '../constants.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  List<Color> gradientColors = [
    Colors.black,
    Colors.black.withOpacity(1),
  ];
  final pomoController = Get.find<PomoController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pomoController.showStreakBadge.value = false;

      // executes after build
    });
    super.initState();
  }

  //get the pomo COntroller
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analytics Center",
          style: TextStyle(
            fontFamily: "Inter",
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xffFF4500).withOpacity(0.8),
        // backgroundColor: Colors.transparent,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Container(
            //give a linear gradient to the background
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                tileMode: TileMode.clamp,
                stops: const [
                  0.1,
                  1,
                ],
                colors: [
                  const Color(0xffFF4500).withOpacity(0.8),
                  const Color(0xffFF4500).withOpacity(0.4),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _listTile(
                      CupertinoIcons.flame_fill,
                      "Highest Streak",
                      "You have the highest streak of ${pomoController.user.longestStreak} Focus Sessions in a row.",
                      true),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Flexible(
                          flex: 1,
                          child: _listTile(
                              null,
                              "Today's Sessions",
                              pomoController.todaysSessionsNum.toString(),
                              false)),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                          flex: 1,
                          child: _listTile(
                              null,
                              "Today's Focus",
                              calculateFocusHoursFromMin(
                                  pomoController.todaysFocusMin),
                              false)),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                          flex: 1,
                          child: _listTile(
                              null,
                              "Net Focus Time",
                              calculateFocusHoursFromMin(
                                  pomoController.netFocusMin),
                              false)),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Daily Average",
                                  style: TextStyle(
                                    color: Colors.black,
                                    //fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(
                                  height: 0,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      calculateFocusHoursFromMin(
                                          pomoController.calculateDailyAvg()),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        //make it a cricle with green background
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.green,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.arrow_upward,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          AspectRatio(
                            aspectRatio: 1.70,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 18,
                                left: 12,
                                top: 0,
                                bottom: 12,
                              ),
                              child: BarChart(
                                BarChartData(
                                  maxY: 420,
                                  barTouchData: barTouchData,
                                  titlesData: titlesData,
                                  borderData: borderData,
                                  barGroups: barGroups,
                                  alignment: BarChartAlignment.spaceAround,
                                  gridData: FlGridData(
                                    show: false,
                                    checkToShowHorizontalLine: (value) =>
                                        value % 5 == 0,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.black.withOpacity(0.5),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                                swapAnimationDuration: const Duration(
                                    milliseconds: 150), // Optional
                                swapAnimationCurve: Curves.linear, // O
                              ),
                            ),
                          ),
                        ],
                      ),
                      // ptional
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //build a grid view of chips usinf _listTile
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: pomoController.focusChipsTexts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 2.5,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Icon(
                                pomoController.focusChipsTexts.values
                                    .elementAt(index)[0],
                                size: 25,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                pomoController.focusChipsTexts.keys
                                    .elementAt(index),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "${calculateFocusHoursFromMin(pomoController.focusMinByChips.values.elementAt(index))} | ${pomoController.sessionsByChip.values.elementAt(index)} sessions",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _listTile(
      IconData? icon, String title, String subtitle, bool allowIcon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.2),
      ),
      child: ListTile(
        minLeadingWidth: 0,
        title: allowIcon
            ? Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Inter",
                      color: Colors.black87,
                      height: 2,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: const TextStyle(
                  fontFamily: "Inter",
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                  height: 1.2,
                  fontSize: 14,
                ),
              ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.black.withOpacity(1),
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
        subtitleTextStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 10,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              calculateFocusHoursFromMin(rod.toY.round()) == "0m"
                  ? ""
                  : calculateFocusHoursFromMin(rod.toY.round()),
              const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mn';
        break;
      case 1:
        text = 'Tu';
        break;
      case 2:
        text = 'Wd';
        break;
      case 3:
        text = 'Th';
        break;
      case 4:
        text = 'Fr';
        break;
      case 5:
        text = 'St';
        break;
      case 6:
        text = 'Sn';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Colors.orange.withOpacity(0.5),
          Colors.red,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );
  List<BarChartGroupData> get barGroups => pomoController.focusMinByDay.keys
      .map(
        (e) => BarChartGroupData(
          x: pomoController.focusMinByDay.keys.toList().indexOf(e),
          barRods: [
            BarChartRodData(
              toY: pomoController.focusMinByDay[e]!.toDouble(),
              gradient: _barsGradient,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      )
      .toList();
}
