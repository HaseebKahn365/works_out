import 'package:intl/intl.dart';

void main() {
  // Get today's date
  DateTime now = DateTime.now();

// Format the date as an 8-digit integer (YYYYMMDD)
  String key = DateFormat('yyyyMMdd').format(now);

  print(key); // Output: 20230719 (for July 19, 2023)

  Map<String, int> pushMasterMap = {
    '20230824': 37,
    '20230825': 38,
    '20230826': 39,
    '20230827': 40,
    '20230828': 41,
    '20230829': 42,
    '20230830': 43,
    '20230831': 44,
    '20230901': 45,
    '20230802': 46,

    '20230804': 48,
    '20230805': 49,
    //processing the above for a week's graph should have a list like : [0,0,45,46,0,48,49]
  };

  int currentYear = DateTime.now().year;
  int currentMonth = DateTime.now().month;

  List<int> last7DaysValues = [];
  int todayDay = DateTime.now().day;

  for (int i = 0; i < 7; i++) {
    int targetDay = todayDay - i;
    int targetDate = currentYear * 10000 + currentMonth * 100 + targetDay;

    if (pushMasterMap.containsKey(targetDate.toString())) {
      last7DaysValues.add(pushMasterMap[targetDate.toString()]!);
    } else {
      last7DaysValues.add(0);
    }
  }

  last7DaysValues = last7DaysValues.reversed.toList(); // Reverse the list to match the order
  print(last7DaysValues);
}
