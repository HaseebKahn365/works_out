import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/*Here is what i want to do. i want the create a custom workout button to create a customWorkout widget. i also want to be able to store these workout in devices' documents
directory in a file using a String only. i want to be able to retrieve these workouts and display them in a listview. i want to be able to edit the workouts and save them. 
Take a look at the following functions: */

String encodedWorkouts = '';
List<CustomWorkout> customWorkoutList = [];

class CustomWorkout extends StatefulWidget {
  String label;
  int countToday;
  int countTotal;

  CustomWorkout({super.key, this.label = '', this.countToday = 0, this.countTotal = 0});

  static void encode(List<CustomWorkout> customWorkoutList) {
    for (var wo in customWorkoutList) {
      String label = wo.label;
      int countToday = wo.countToday;
      int countTotal = wo.countTotal;
      String encodedWorkout = '$label,$countToday,$countTotal@'; //@ is used as a separator for workouts
      encodedWorkouts += encodedWorkout;
    }
  }

  static decode(String encodedWorkouts) {
    List<String> encodedWorkoutList = encodedWorkouts.split('@');
    if (encodedWorkouts == '') {
      print('No workouts found');
    } else {
      for (var encodedWorkout in encodedWorkoutList) {
        if (encodedWorkout == '') {
          break;
        }
        List<String> workout = encodedWorkout.split(',');

        String label = workout[0];
        int countToday = int.parse(workout[1]);
        int countTotal = int.parse(workout[2]);
        CustomWorkout customWorkout = CustomWorkout(label: label, countToday: countToday, countTotal: countTotal);
        customWorkoutList.add(customWorkout);
      }
      print('customworkout modified');
    }
  }

  static saveWorkouts() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/workouts.txt');
    await file.writeAsString(encodedWorkouts);
  }

  static loadWorkouts() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/workouts.txt');
    encodedWorkouts = await file.readAsString();
    decode(encodedWorkouts);
  }

  @override
  State<CustomWorkout> createState() => _CustomWorkoutState();
}

class _CustomWorkoutState extends State<CustomWorkout> {
  final TextEditingController _textFieldControllerForNewWorkout = TextEditingController();
  int countNow = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 55,
          child: TextField(
            controller: _textFieldControllerForNewWorkout,
            // Limit the length to 20 characters
            decoration: InputDecoration(
              hintText: widget.label,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (String value) {
              setState(() {
                //parse the controller to int and set it to the countToday
                countNow = int.parse(_textFieldControllerForNewWorkout.text);
                widget.countToday += countNow;
                widget.countTotal += widget.countToday;
              });
              _textFieldControllerForNewWorkout.clear();
            },

            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('did: ${countNow}'),
              Text('today: ${widget.countToday}'),
              Text('total: ${widget.countTotal}'),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(height: 0.0, thickness: 0.1, color: Colors.grey),
        const SizedBox(
          height: 30,
        )
      ],
    );
  }
}

/* 
When i tap on the create custom workout i should be able to create a custom workout widget and add it to the list of List<CustomWorkout> customWorkoutList = [];
I should be able to display the customWorkoutList in a listview. 





 */
