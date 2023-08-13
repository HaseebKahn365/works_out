import 'package:flutter/material.dart';
import 'package:works_out/Widgets/radial_painter.dart';
import 'package:works_out/helpers/firebase_uploader.dart';

import 'helpers/CustomWorkouts.dart';
import 'helpers/colors_helper.dart';

const Widget divider = SizedBox(height: 10);

// If screen content width is greater or equal to this value, the light and dark
// color schemes will be displayed in a column. Otherwise, they will
// be displayed in a row.
const double narrowScreenWidthThreshold = 400;

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    Color selectedColor = Theme.of(context).primaryColor;
    ThemeData lightTheme = ThemeData(colorSchemeSeed: selectedColor, brightness: Brightness.light);

    Widget schemeLabel(String brightness) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text(
          brightness,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    Widget schemeView(ThemeData theme) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ColorSchemeView(
          colorScheme: theme.colorScheme,
        ),
      );
    }

    return Expanded(
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < narrowScreenWidthThreshold) {
          return SingleChildScrollView(
            child: Column(
              children: [
                schemeView(lightTheme),
                divider,
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        schemeLabel("Light Theme"),
                        schemeView(lightTheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}

class ColorSchemeView extends StatefulWidget {
  const ColorSchemeView({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  State<ColorSchemeView> createState() => _ColorSchemeViewState();
}

class _ColorSchemeViewState extends State<ColorSchemeView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 300,
          child: Card(
            color: Theme.of(context).colorScheme.onInverseSurface,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 0,
            margin: const EdgeInsets.all(5.7),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomPaint(
                foregroundPainter: RadialPainter(
                    bgColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.15),
                    lineColor: getColor(context, 0.7),
                    percent: (locDocDayRec != null && locDocDayRec != 0) ? locDocDayRec! / locDocBestDay! : 0,
                    width: 12.0),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ' ${locDocBestDay == null || locDocDayRec == null || (locDocBestDay! - locDocDayRec! == 0) ? '🎊 Your new record 🎊' : 'Remaining: ${locDocBestDay! - locDocDayRec!}'}',
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Best: ${locDocBestDay == null ? 'N/A' : locDocBestDay} !',
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),

        //I have left the below group to show the text data that will come from firestore.
        ColorGroup(
          children: [
            ColorChip(
              label: 'Your Ranking',
              number: 'Coming soon!',
              color: widget.colorScheme.primary,
            ),
            ColorChip(
                label: 'Today\'s Score', number: locDocDayRec.toString(), color: widget.colorScheme.primaryContainer),
            ColorChip(
                label: 'Week\'s Score', number: locDocWeekRec.toString(), color: widget.colorScheme.primaryContainer),
            ColorChip(
                label: 'Month\'s Score', number: locDocMonthRec.toString(), color: widget.colorScheme.primaryContainer),
            ColorChip(
                label: 'Year\'s Score', number: locDocYearRec.toString(), color: widget.colorScheme.primaryContainer),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        //create another ColorGroup from customWorkoutslist.
        //This will be a list of all the workouts that the user has created.
        //The user will be able to tap on the workout and see the total counts for that workout.
        ColorGroup(
          children: [
            ColorChip(
              label: 'Custom Workouts',
              number: 'Total Counts',
              color: widget.colorScheme.primary,
            ),

            //running a loop through the customWorkoutsList and returning a ColorChip for each workout.
            for (var item in customWorkoutList)
              ColorChip(
                label: item.label,
                number: item.countTotal.toString(),
                color: widget.colorScheme.primaryContainer,
              )
          ],
        ),
      ],
    );
  }
}

class ColorGroup extends StatelessWidget {
  const ColorGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }
}

class ColorChip extends StatelessWidget {
  const ColorChip({
    super.key,
    required this.color,
    required this.number,
    required this.label,
    this.onColor,
  });

  final Color color;
  final Color? onColor;
  final String label;
  final String number;

  static Color contrastColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    switch (brightness) {
      case Brightness.dark:
        return Colors.white;
      case Brightness.light:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color labelColor = onColor ?? contrastColor(color);

    return Container(
      width: 320,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Text(
                    label,
                    style: TextStyle(color: labelColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Text(
                    number,
                    style: TextStyle(color: labelColor),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
