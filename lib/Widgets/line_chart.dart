//lets create some beutiful charts using fl chart that i just installed. I wiil be using the following data sources:
//customWorkoutList, it contains all the custom workout objects so filter it down to just countToday.
//weekGraphPushData, it is a list of int values ready to draw a chart.
//weekGraphPullData, it is a list of int values ready to draw a chart.
//the first LineChart is about weekGraphPushData which is a list of 7 int values.

// ignore_for_file: prefer_const_constructors

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<int> listOf7dDays;
  const LineChartWidget({super.key, required this.listOf7dDays});

  @override
  Widget build(BuildContext context) {
    final maxCountInList = listOf7dDays.reduce((curr, next) => curr > next ? curr : next);
    return Container(
      padding: EdgeInsets.all(15),
      width: 315,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      height: 300,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 7,
          minY: 0,
          maxY: maxCountInList + 50,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Theme.of(context).colorScheme.onSecondary,
              tooltipRoundedRadius: 10,
              tooltipPadding: EdgeInsets.all(5),
              tooltipMargin: 10,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  // if (flSpot.x == 0 || flSpot.x == 6) {
                  //   return null;
                  // }
                  return LineTooltipItem(
                    flSpot.y.toInt().toString(),
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            //add some spacing between chart and titles
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                //showing days number
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                //showing pushups number
                getTitlesWidget: (value, meta) => Text(
                  (value == 0) ? '' : value.toInt().toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
                interval: (maxCountInList > 150) ? 100 : 50,
                reservedSize: 22,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.12),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.04),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.12),
              width: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(1, listOf7dDays[0].toDouble()),
                FlSpot(2, listOf7dDays[1].toDouble()),
                FlSpot(3, listOf7dDays[2].toDouble()),
                FlSpot(4, listOf7dDays[3].toDouble()),
                FlSpot(5, listOf7dDays[4].toDouble()),
                FlSpot(6, listOf7dDays[5].toDouble()),
                FlSpot(7, listOf7dDays[6].toDouble()),
              ],
              isCurved: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
                ],
                stops: const [
                  0.0,
                  1.0,
                ],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                //gradiet colors should be from top to bottom
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.primary.withOpacity(0.01),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
