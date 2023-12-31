// ignore_for_file: prefer_const_constructors
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:works_out/helpers/CustomWorkouts.dart';
import 'package:works_out/main.dart';

import 'package:works_out/typography_screen.dart';

import 'helpers/firebase_uploader.dart';

//the following boolean variable is is responsible for update the locDocPushCount and locDocPullCount variables only once when the component screen is loaded
bool isComponentScreenLoaded = false;

//These are the motivational welcome messages:

List<String> welcomeMessages = [
  "Hey Tiger!",
  "Hello Champ!",
  "Welcome, Superstar!",
  "Greetings, Fitness Enthusiast!",
  "Hey, Workout Warrior!",
  "Hello, Health Fanatic!",
  "Welcome, Exercise Aficionado!",
  "Hey there, Fitness Freak!",
  "Greetings, Gym Junkie!",
  "Hello, Exercise Addict!",
];

String getRandomWelcomeMessage() {
  Random random = Random();
  int index = random.nextInt(welcomeMessages.length);
  return welcomeMessages[index];
}

final String welcomeMessage = getRandomWelcomeMessage();
String pushUpControllerCount = '0';
String pullUpControllerCount = '0';

class ComponentScreen extends StatefulWidget {
  ComponentScreen({Key? key, required this.showNavBottomBar, required this.textTheme});
  final TextTheme textTheme;
  final bool showNavBottomBar;

  @override
  State<ComponentScreen> createState() => _ComponentScreenState();
}

class _ComponentScreenState extends State<ComponentScreen> {
  bool showLinearProgressIndicator = false; //used when uploading data to firestore

  final FocusNode _textFieldFocusNode1 = FocusNode();

  final FocusNode _textFieldFocusNode2 = FocusNode();

  bool onlineStatus = false;

  final TextEditingController pushUpController = TextEditingController();
  final TextEditingController pullUpController = TextEditingController();
  final TextEditingController _textFieldControllerForNewWorkout = TextEditingController();

  // ignore: unused_field
  late Future<void> _initDataFuture;

  @override
  void initState() {
    //also load the custom workouts from the local storage

    if (isComponentScreenLoaded == false) {
      _initDataFuture = _initData();
      isComponentScreenLoaded = true;
    }
    super.initState();
  }

  Future<void> _initData() async {
    // Assuming submitFormOnSave() returns a Future that fetches data from Firestore
    // For demonstration purposes, let's assume it's fetching push-up and pull-up data
    await Future.wait([
      submitFormOnSave(),
      // Any other data fetching from Firestore can be added here
    ]);
    setState(() {
      // Update the UI state after all data fetching is complete
      locDocPushCount;
      locDocPullCount;
    });
  }

  @override
  void dispose() {
    pushUpController.dispose();
    _textFieldFocusNode1.dispose();
    pullUpController.dispose();
    _textFieldFocusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: _maxWidthConstraint,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextStyleExample(
                  name: welcomeMessage,
                  style: textTheme.displaySmall!,
                ),

                widget.showNavBottomBar
                    ? const NavigationBars(
                        selectedIndex: 0,
                        isExampleBar: true,
                      )
                    : Container(),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 90),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Foreground color
                      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                      // Background color
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                    onPressed: () {
                      //Dialogue for new workout not implemented yet
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'New Workout',
                            style: TextStyle(fontSize: 20),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Image container
                              Container(
                                width: 100,
                                height: 100,

                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                // Replace the 'your_image_path' with your desired image path
                                child: Image.asset('assets/images/stretch.png',
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.5)),
                              ),

                              SizedBox(height: 16),

                              // Text field
                              Container(
                                height: 75,
                                child: TextField(
                                  controller: _textFieldControllerForNewWorkout,
                                  maxLength: 15, // Limit the length to 20 characters
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      FluentIcons.add_12_regular,
                                      color: Theme.of(context).dividerColor,
                                      size: 25,
                                    ),
                                    hintText: 'Workout Title',
                                    border: OutlineInputBorder(),
                                  ),
                                  buildCounter: (BuildContext context,
                                      {int? currentLength, int? maxLength, bool? isFocused}) {
                                    currentLength ??= 0;
                                    return Text('${(15 - currentLength)} left', style: TextStyle(fontSize: 11));
                                  },
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Create a new custom workout and add it to the list
                                CustomWorkout newWorkout = CustomWorkout(
                                  label: _textFieldControllerForNewWorkout.text,
                                  countToday: 0,
                                  countTotal: 0,
                                );
                                customWorkoutList.add(newWorkout);

                                // Encode and save the updated custom workouts to local storage

                                CustomWorkout.saveAndUpdate();

                                // Trigger a UI update
                                setState(() {});

                                Navigator.of(context).pop(); // Close the alert box
                              },
                              child: Text('Create'),
                            ),

                            //create a text button
                          ],
                        ),
                      );
                    },
                    child: const Text('Create workout'),
                  ),
                ),
                //show linear progress indicator here:

                (showLinearProgressIndicator == true)
                    ? const Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          LinearProgressIndicator(),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 15,
                      ),

                // Text field
                Padding(
                  padding: _symmetricPad,
                  child: Container(
                    child: TextField(
                      controller: pushUpController,
                      focusNode: _textFieldFocusNode1,
                      maxLength: 3,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(17),
                        prefixIcon: Icon(
                          _textFieldFocusNode1.hasFocus ? FluentIcons.edit_20_filled : FluentIcons.edit_20_regular,
                          color:
                              (int.tryParse(pushUpController.text) == 0) ? Colors.red : Theme.of(context).dividerColor,
                          size: 25,
                        ),
                        hintText: 'PushUps',
                        helperText: 'Today\'s count : ${(locDocPushCount) ?? 'loading...'}',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) {
                        currentLength ??= 0;
                        return Text('Topper Gap: Pending', style: TextStyle(fontSize: 11));
                      },
                      onChanged: (String value) {
                        setState(() {
                          // Update the state when the text field value changes
                          if (pushUpController.text != '') {
                            pushUpControllerCount = pushUpController.text;
                          } else {
                            pushUpControllerCount = '0'; // Reset to '0' if the text is empty
                          }
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          pushUpControllerCount =
                              pushUpController.text; // Update the count variable on editing complete
                        });
                        FocusScope.of(context).requestFocus(_textFieldFocusNode2);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // Text field for pullups
                Padding(
                  padding: _symmetricPad,
                  child: Container(
                    child: TextField(
                      controller: pullUpController,
                      focusNode: _textFieldFocusNode2,
                      maxLength: 3,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(17),
                        prefixIcon: Icon(
                          _textFieldFocusNode2.hasFocus ? FluentIcons.edit_20_filled : FluentIcons.edit_20_regular,
                          color:
                              (int.tryParse(pullUpController.text) == 0) ? Colors.red : Theme.of(context).dividerColor,
                          size: 25,
                        ),
                        hintText: 'PullUps',
                        helperText: 'Today\'s count : ${(locDocPullCount) ?? 'loading...'}',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) {
                        currentLength ??= 0;
                        return Text('Topper Gap: Pending', style: TextStyle(fontSize: 11));
                      }, //This will indicate the difference between the top scorer and the current user after data from the database is fetched
                      onChanged: (String value) {
                        setState(() {
                          // Update the state when the text field value changes
                          if (pullUpController.text != '') {
                            pullUpControllerCount = pullUpController.text;
                          } else {
                            pullUpControllerCount = '0'; // Reset to '0' if the text is empty
                          }
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          pullUpControllerCount =
                              pullUpController.text; // Update the count variable on editing complete
                        });
                        _textFieldFocusNode2.unfocus(); //pullups field unfocus .unfocus();
                      },
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        child: TextButton(
                      onPressed: () {
                        pushUpController.clear();
                        pullUpController.clear();
                        isImageChanged = false;
                        userNameController = '';
                      },
                      child: const Text('Cancel'),
                    )),
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // Foreground color
                          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          // Background color
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                        onPressed: () {
                          //I should be able to save the CustomWorkoutList to the local storage

                          int pushUpValue = int.tryParse(pushUpController.text) ?? 0;
                          int pullUpValue = int.tryParse(pullUpController.text) ?? 0;

                          if (pushUpValue >= 10 && pushUpValue < 267 || pullUpValue > 5 && pullUpValue < 110) {
                            setState(() {
                              showLinearProgressIndicator = true;
                            });
                            submitFormOnSave().then((value) {
                              clearTextFieldsAndCounters();
                              _textFieldFocusNode2.unfocus();
                              _textFieldFocusNode1.unfocus();

                              setState(() {
                                showLinearProgressIndicator = false;
                              });
                            });
                          }
                          if (pushUpValue > 0) {
                            if (pushUpValue < 10) {
                              showCustomSnackBar(context, 'Try doing more pushups');
                            } else if (pushUpValue > 266) {
                              showCustomSnackBar(context, 'You are violating rules. Your account could be blocked!');
                            }
                          }

                          if (pullUpValue > 0) {
                            if (pullUpValue < 5) {
                              showCustomSnackBar(context, 'Try doing more pullups');
                            } else if (pullUpValue > 109) {
                              showCustomSnackBar(context, 'You are violating rules. Your account could be blocked!');
                            }
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                //if null then display a text that says 'No custom workouts created yet'
                //if not null then display the list of custom workouts
                //the list of custom workouts should be scrollable
                if (customWorkoutList.length == 0) Text('No custom workouts created yet'),
                for (var customWorkout in customWorkoutList)
                  CustomWorkout(
                    label: customWorkout.label,
                    countToday: customWorkout.countToday,
                    countTotal: customWorkout.countTotal,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //function to clear the controllers:
  void clearTextFieldsAndCounters() {
    setState(() {
      pushUpController.clear();
      pullUpController.clear();
      pushUpControllerCount = '0';
      pullUpControllerCount = '0';
    });
  }
}

const _rowDivider = SizedBox(width: 10);
const _colDivider = SizedBox(height: 10);
const _symmetricPad = EdgeInsets.symmetric(horizontal: 5);
const double _cardWidth = 115;
const double _maxWidthConstraint = 400;

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: "",
    icon: Icon(
      FluentIcons.add_square_multiple_20_regular,
      size: 30,
    ),
    label: 'Update',
    selectedIcon: Icon(FluentIcons.add_square_multiple_20_filled, size: 30),
  ),
  NavigationDestination(
    tooltip: "",
    icon: Icon(FluentIcons.stack_star_16_regular, size: 27),
    label: 'Stats',
    selectedIcon: Icon(FluentIcons.stack_star_16_filled, size: 27),
  ),
  NavigationDestination(
    tooltip: "",
    icon: Icon(FluentIcons.people_team_16_regular, size: 27),
    label: 'People',
    selectedIcon: Icon(FluentIcons.people_team_16_filled, size: 27),
  ),
];

final List<NavigationRailDestination> navRailDestinations = appBarDestinations
    .map(
      (destination) => NavigationRailDestination(
        icon: Tooltip(
          message: destination.label,
          child: destination.icon,
        ),
        selectedIcon: Tooltip(
          message: destination.label,
          child: destination.selectedIcon,
        ),
        label: Text(destination.label),
      ),
    )
    .toList();

const List<Widget> exampleBarDestinations = [
  NavigationDestination(
    tooltip: "",
    icon: Icon(Icons.explore_outlined),
    label: 'Explore',
    selectedIcon: Icon(Icons.explore),
  ),
  NavigationDestination(
    tooltip: "",
    icon: Icon(Icons.pets_outlined),
    label: 'Pets',
    selectedIcon: Icon(Icons.pets),
  ),
  NavigationDestination(
    tooltip: "",
    icon: Icon(Icons.account_box_outlined),
    label: 'Account',
    selectedIcon: Icon(Icons.account_box),
  )
];

class NavigationBars extends StatefulWidget {
  final void Function(int)? onSelectItem;
  final int selectedIndex;
  final bool isExampleBar;

  const NavigationBars({super.key, this.onSelectItem, required this.selectedIndex, required this.isExampleBar});

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if (!widget.isExampleBar) widget.onSelectItem!(index);
      },
      destinations: widget.isExampleBar ? exampleBarDestinations : appBarDestinations,
    );
  }
}

class NavigationRailSection extends StatefulWidget {
  final void Function(int) onSelectItem;
  final int selectedIndex;

  const NavigationRailSection({super.key, required this.onSelectItem, required this.selectedIndex});

  @override
  State<NavigationRailSection> createState() => _NavigationRailSectionState();
}

class _NavigationRailSectionState extends State<NavigationRailSection> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      minWidth: 50,
      destinations: navRailDestinations,
      selectedIndex: _selectedIndex,
      useIndicator: true,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.onSelectItem(index);
      },
    );
  }
}

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2), // Adjust the duration as needed
      behavior: SnackBarBehavior.floating, // Set the behavior to floating if you prefer
    ),
  );
}
