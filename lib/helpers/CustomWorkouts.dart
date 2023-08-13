import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/*Eerything works great. Now i need to make sure that today and total are not just the same. it today 

*/

String encodedWorkouts = '';
List<CustomWorkout> customWorkoutList = [];

class CustomWorkout extends StatefulWidget {
  String label;
  int countToday;
  int countTotal;

  CustomWorkout({super.key, required this.label, required this.countToday, required this.countTotal});

  static Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.txt');
    if (file.existsSync()) {
      final encodedWorkouts = await file.readAsString();
      decode(encodedWorkouts);
    }
  }

  static void saveAndUpdate() async {
    encode(customWorkoutList);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.txt');
    await file.writeAsString(encodedWorkouts);
  }

  static void addWorkout(CustomWorkout workout) {
    customWorkoutList.add(workout);
    saveAndUpdate();
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
        List<String> workout = encodedWorkout.split(',').toList();

        String label = workout[0];
        int countToday = int.parse(workout[1]);
        int countTotal = int.parse(workout[2]);
        CustomWorkout customWorkout = CustomWorkout(label: label, countToday: countToday, countTotal: countTotal);
        customWorkoutList.add(customWorkout);
      }
    }
  }

  static void encode(List<CustomWorkout> customWorkoutList) {
    encodedWorkouts = '';
    for (var wo in customWorkoutList) {
      String label = wo.label;
      int countToday = wo.countToday;
      int countTotal = wo.countTotal;
      String encodedWorkout = '$label,$countToday,$countTotal@';
      encodedWorkouts += encodedWorkout;
    }
    print('encodedWorkouts after encoding: $encodedWorkouts');
  }

  @override
  State<CustomWorkout> createState() => _CustomWorkoutState();
}

class _CustomWorkoutState extends State<CustomWorkout> {
  final TextEditingController _textFieldControllerForNewWorkout = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  int countNow = 0;

  @override
  void dispose() {
    _textFieldControllerForNewWorkout.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }
  //THe user should be able to delete the customWorkout as well by long pressing the delete iconButton:

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 55,
          width: 320,
          child: Builder(builder: (BuildContext context) {
            return TextField(
              controller: _textFieldControllerForNewWorkout,
              // Limit the length to 20 characters
              decoration: InputDecoration(
                hintText: widget.label,
                border: const OutlineInputBorder(),
                suffixIcon: GestureDetector(
                  child: IconButton(
                    icon: Icon(
                      //use fluent delete icon
                      FluentIcons.delete_24_regular,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    //it should be on long press and also show a confirmation dialog
                    onPressed: () {},
                  ),
                  onLongPress: () {
                    // Show a confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete this workout?'),
                          content: const Text('This will delete the workout from the list of custom workouts.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  customWorkoutList.removeWhere((workout) => workout.label == widget.label);
                                  CustomWorkout.saveAndUpdate();
                                  widget.label = 'Deleted';
                                  _textFieldControllerForNewWorkout.clear();
                                });
                                Navigator.of(context).pop();
                                //i need to refresh the page so that the workout is removed from the list of custom workouts using navigator.pushReplacement
                              },
                              child: const Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              onSubmitted: (String value) {
                setState(() {
                  countNow = int.parse(_textFieldControllerForNewWorkout.text);
                  widget.countToday += countNow;
                  widget.countTotal += countNow;

                  final customWorkout = customWorkoutList.firstWhere((workout) => workout.label == widget.label);
                  customWorkout.countToday = widget.countToday;
                  customWorkout.countTotal = widget.countTotal;

                  // Update the customWorkoutList after modifying the workout

                  CustomWorkout.saveAndUpdate();
                });
                _textFieldControllerForNewWorkout.clear();
              },

              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Now: ${countNow}', style: const TextStyle(fontSize: 12)),
              Text('Today: ${widget.countToday}', style: const TextStyle(fontSize: 12)),
              Text('Total: ${widget.countTotal}', style: const TextStyle(fontSize: 12)),
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
