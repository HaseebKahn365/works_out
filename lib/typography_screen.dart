import 'package:flutter/material.dart';

class TypographyScreen extends StatefulWidget {
  const TypographyScreen({Key? key});

  @override
  State<TypographyScreen> createState() => _TypographyScreenState();
}

class _TypographyScreenState extends State<TypographyScreen> {
  //list of top 10 atheletes
  final List<Map<String, String>> dataList = [
    {'title': 'Athlete 1', 'subtitle': 'feature coming soon'},
    {'title': 'Athlete 2', 'subtitle': 'feature coming soon'},
    {'title': 'Athlete 3', 'subtitle': 'feature coming soon'},
    {'title': 'Athlete 4', 'subtitle': 'feature coming soon'},
    // Add more data as needed
  ];
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Expanded(
      child: ListView.builder(
          itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(20.0),
                height: 150.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dataList[index]['title']!, style: textTheme.headlineSmall),
                    Text(dataList[index]['subtitle']!, style: textTheme.titleMedium),
                  ],
                ),
              ),
          itemCount: dataList.length),
    );
  }
}

class TextStyleExample extends StatelessWidget {
  const TextStyleExample({
    Key? key,
    required this.name,
    required this.style,
  }) : super(key: key);

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(name, style: style),
    );
  }
}
