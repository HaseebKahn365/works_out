import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:works_out/helpers/CustomWorkouts.dart';

class CustomPieChart extends StatefulWidget {
  const CustomPieChart({super.key});

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  @override
  Widget build(BuildContext context) {
    //calculate the sum of all customWorkout.countTotal
    //decorate the workout title in a container
    final totalcount = customWorkoutList.fold(0, (sum, item) => sum + item.countTotal);
    return Container(
      padding: EdgeInsets.all(15),
      width: 315,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: PieChart(
        PieChartData(
          sections: customWorkoutList.map((customWorkout) {
            return PieChartSectionData(
              color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
              value: customWorkout.countTotal / totalcount,
              title: '',
              badgeWidget: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
                child: Text(
                  customWorkout.label + ' :  ' + customWorkout.countTotal.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
              radius: 100,
              titleStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 12,
              ),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                width: 1,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
