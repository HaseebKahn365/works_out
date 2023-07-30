//Function that will intialize the document for the user if it doesn't exist or update it if it does exist:

// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:works_out/component_screen.dart';

import '../main.dart';

//local varables to
bool? locDocIsHaseeb;
String? locDocUserImage;
String locDocUserName = 'Anonymous';
String? locDocEmail = user!.email;
String? locDocPassword;
int? locDocPushCount;
int? locDocPullCount;
int? locDocDayToday;
int? locDocDayRec;
int? locDocWeek; //problem: it will be int for 4 in 1 month	Date / 7
int? locDocWeekRec;
int? locDocMonth;
int? locDocMonthRec;
int? locDocYear;
int? locDocYearRec;
int? locDocBestDay;
int? locDocBestWeek;
int? locDocBestMonth;
bool? locDocIsBlocked;
Map<String, int> locDocYearMap = {};

Future submitFormOnSave() async {
  final uid = user!.uid;
  print('pushupCount: $pushUpControllerCount');
  print('pullupCount: $pullUpControllerCount');

  try {
    // Check if the document exists using the get method
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // These are the variables that will represent the document fields used for initialization and also downloading fields;
    bool isHaseeb;
    String? userImage;
    String userName;
    String? email;
    String? password;
    int pushCount;
    int pullCount;
    int docDay;
    int docDayRec;
    int docWeek;
    int docWeekRec;
    int docMonth;
    int docMonthRec;
    int docYear;
    int docYearRec;
    int bestDay;
    int bestWeek;
    int bestMonth;
    bool isBlocked;
    Map<String, int> docYearMap = {};

    late String userImageUrl;
    if (!docSnapshot.exists) {
      // Document does not exist, initialize data and set the document

      print('isImageChanged: $isImageChanged');
      print('userImageFile: $userImageFile');

      isHaseeb = false;
      userImage = null; // Set the initial value for userImage
      userName = 'Anonymous';
      email = user!.email;
      password = 'patha nastha no';
      pushCount = 0;
      pullCount = 0;
      docDay = DateTime.now().day;
      docDayRec = 0;
      docWeek = (DateTime.now().day ~/ 7); // Problem: it will be int for 4 in 1 month (Date / 7)
      docWeekRec = 0;
      docMonth = DateTime.now().month;
      docMonthRec = 0;
      docYear = DateTime.now().year;
      docYearRec = 0;
      bestDay = 0;
      bestWeek = 0;
      bestMonth = 0;
      isBlocked = false;
      docYearMap = {'$docYear': 0};

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userImage': userImage,
        'userName': userName,
        'isHaseeb': isHaseeb,
        'uid': uid,
        'email': email,
        'password': password,
        // 'dayToday': dayToday.toString(), we do need this to be in the firestore for comparing document day with today's day
        'pushCount': pushCount,
        'pullCount': pullCount,
        'docDay': docDay,
        'docDayRec': docDayRec,
        'docWeek': docWeek,
        'docWeekRec': docWeekRec,
        'docMonth': docMonth,
        'docMonthRec': docMonthRec,
        'docYear': docYear,
        'docYearRec': docYearRec,
        'bestDay': bestDay,
        'bestWeek': bestWeek,
        'bestMonth': bestMonth,
        'isBlocked': isBlocked,
        'docYearMap': docYearMap,
        'createdAt': Timestamp.now(),
      });

      print('Data uploaded successfully to Firestore!');
    } else {
      print('Document already exists in Firestore!');

      print('isImageChanged: $isImageChanged');
      print('userImageFile: $userImageFile');

      if (isImageChanged == true) {
        final ref = FirebaseStorage.instance.ref().child('userImages').child('$uid.jpg');
        await ref.putFile(userImageFile!);
        userImageUrl = await ref.getDownloadURL();
      }

      // Download data and assign it to the variables
      Map<String, dynamic> data = docSnapshot.data()!;
      isHaseeb = data['isHaseeb'] ?? false;
      userImage = data['userImage'];
      userName = data['userName'] ?? 'Anonymous';
      email = data['email'];
      password = data['password'] ?? 'patha nastha no';
      pushCount = data['pushCount'] ?? 0;
      pullCount = data['pullCount'] ?? 0;
      docDay = data['docDay'] ?? 0;
      docDayRec = data['docDayRec'] ?? 0;
      docWeek = data['docWeek'] ?? 0;
      docWeekRec = data['docWeekRec'] ?? 0;
      docMonth = data['docMonth'] ?? 0;
      docMonthRec = data['docMonthRec'] ?? 0;
      docYear = data['docYear'] ?? 0;
      docYearRec = data['docYearRec'] ?? 0;
      bestDay = data['bestDay'] ?? 0;
      bestWeek = data['bestWeek'] ?? 0;
      bestMonth = data['bestMonth'] ?? 0;
      isBlocked = data['isBlocked'] ?? false;
      docYearMap = Map<String, int>.from(data['docYearMap'] ?? {});
      // Printing the above variables to see if they are properly downloaded
      // Download data and assign it to the variables
      // Use null-aware operators to handle nullable fields
      print('isHaseeb: $isHaseeb');
      print('userImage: $userImage');
      print('userName: $userName');
      print('email: $email');
      print('password: $password');
      print('pushCount: $pushCount');
      print('pullCount: $pullCount');
      print('docDay: $docDay');
      print('docDayRec: $docDayRec');
      print('docWeek: $docWeek');
      print('docWeekRec: $docWeekRec');
      print('docMonth: $docMonth');
      print('docMonthRec: $docMonthRec');
      print('docYear: $docYear');
      print('docYearRec: $docYearRec');
      print('bestDay: $bestDay');
      print('bestWeek: $bestWeek');
      print('bestMonth: $bestMonth');
      print('isBlocked: $isBlocked');
      print('docYearMap: $docYearMap');

      // loading the downloading data onto the local variables for use.
      locDocIsHaseeb = isHaseeb;
      locDocUserImage = userImage;
      locDocUserName = userName;
      locDocEmail = email;
      locDocPassword = password;
      locDocPushCount = pushCount;
      locDocPullCount = pullCount;
      locDocDayToday = docDay;
      locDocDayRec = docDayRec;
      locDocWeek = docWeek;
      locDocWeekRec = docWeekRec;
      locDocMonth = docMonth;
      locDocMonthRec = docMonthRec;
      locDocYear = docYear;
      locDocYearRec = docYearRec;
      locDocBestDay = bestDay;
      locDocBestWeek = bestWeek;
      locDocBestMonth = bestMonth;
      locDocIsBlocked = isBlocked;
      locDocYearMap = docYearMap;

//calculating score before modifying the local variables

      // Updating the document with the newly calculated score data
      final calculatedScore =
          calculateScore(pushupController: pushUpControllerCount, pullupController: pullUpControllerCount);

      //updating the year map before the year changes
      if (locDocYear == DateTime.now().year) {
        locDocYearMap[DateTime.now().year.toString()] = locDocYearMap[DateTime.now().year.toString()]! +
            calculatedScore; // modifying the value of the current year key
      } else {
        locDocYearMap[DateTime.now().year.toString()] =
            calculatedScore; // it will add previous year key and value to the map after the year changes
        locDocYearMap[DateTime.now().year.toString()] = locDocYearMap[DateTime.now().year.toString()]! +
            calculatedScore; // modifying the value of the current year key
      }

      //updating the yearRecord before the month changes
      if (locDocYear == DateTime.now().year) {
        locDocYearRec = locDocYearRec! + calculatedScore;
      } else {
        locDocYear = DateTime.now().year;
        locDocYearRec = 0; // clears the week if week changes
        locDocYearRec = locDocYearRec! + calculatedScore; // adds the score to the new year
      }

      //updating the monthRecord before the week changes
      if (locDocMonth == DateTime.now().month) {
        locDocMonthRec = locDocMonthRec! + calculatedScore;
        //best week record
        locDocBestMonth = (locDocMonthRec! >= locDocBestMonth!) ? locDocMonthRec : locDocBestMonth;
      } else {
        locDocMonth = DateTime.now().month;
        locDocMonthRec = 0; // clears the week if week changes
        locDocMonthRec = locDocMonthRec! + calculatedScore; // adds the score to the new month

        //best month record
        locDocBestMonth = (locDocMonthRec! >= locDocBestMonth!) ? locDocMonthRec : locDocBestMonth;
      }

      //updating the weekRecord before todayRecord
      if (locDocWeek == (DateTime.now().day ~/ 7)) {
        locDocWeekRec = locDocWeekRec! + calculatedScore;
        //best week record
        locDocBestWeek = (locDocWeekRec! >= locDocBestWeek!) ? locDocWeekRec : locDocBestWeek;
      } else {
        locDocWeek = (DateTime.now().day ~/ 7);
        locDocWeekRec = 0; // clears the week if week changes
        locDocWeekRec = locDocWeekRec! + calculatedScore; // adds the score to the new week
        //best week record
        locDocBestWeek = (locDocWeekRec! >= locDocBestWeek!) ? locDocWeekRec : locDocBestWeek;
      }

      //this will be done in the last to update today's record on same day or if day changes
      if (locDocDayToday == DateTime.now().day) {
        locDocDayRec = locDocDayRec! + calculatedScore;
        //best day record
        locDocBestDay = (locDocDayRec! >= locDocBestDay!) ? locDocDayRec : locDocBestDay;
        //calculate today's pushups:
        locDocPushCount = locDocPushCount! + int.parse(pushUpControllerCount);
        //calculate today's pullups:
        locDocPullCount = locDocPullCount! + int.parse(pullUpControllerCount);
      } else {
        locDocDayToday = DateTime.now().day;
        locDocDayRec = 0;
        locDocPushCount = 0;
        locDocPullCount = 0;
        locDocDayRec = locDocDayRec! + calculatedScore; // adds the score to the new day
        //best day record
        locDocBestDay = (locDocDayRec! >= locDocBestDay!) ? locDocDayRec : locDocBestDay;

        //calculate today's pushups:
        locDocPushCount = locDocPushCount! + int.parse(pushUpControllerCount);
        //calculate today's pullups:
        locDocPullCount = locDocPullCount! + int.parse(pullUpControllerCount);
      }

      //printing modified local variables
      print('locDocIsHaseeb: $locDocIsHaseeb');
      print('locDocUserImage: $locDocUserImage');
      print('locDocUserName: $locDocUserName');
      print('locDocEmail: $locDocEmail');
      print('locDocPassword: $locDocPassword');
      print('locDocPushCount: $locDocPushCount');
      print('locDocPullCount: $locDocPullCount');
      print('locDocDayToday: $locDocDayToday');
      print('locDocDayRec: $locDocDayRec');
      print('locDocWeek: $locDocWeek');
      print('locDocWeekRec: $locDocWeekRec');
      print('locDocMonth: $locDocMonth');
      print('locDocMonthRec: $locDocMonthRec');
      print('locDocYear: $locDocYear');
      print('locDocYearRec: $locDocYearRec');
      print('locDocBestDay: $locDocBestDay');
      print('locDocBestWeek: $locDocBestWeek');
      print('locDocBestMonth: $locDocBestMonth');
      print('locDocIsBlocked: $locDocIsBlocked');
      print('locDocYearMap: $locDocYearMap');

      //reuploading the data to firestore:
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'userImage': (isImageChanged == true) ? userImageUrl : locDocUserImage,
        'userName': ((userNameController != '' && userNameController != null)) ? userNameController! : locDocUserName,
        'isHaseeb': locDocIsHaseeb,
        'uid': uid,
        'email': locDocEmail,
        'password': locDocPassword,
        'pushCount': locDocPushCount,
        'pullCount': locDocPullCount,
        'docDay': locDocDayToday,
        'docDayRec': locDocDayRec,
        'docWeek': locDocWeek,
        'docWeekRec': locDocWeekRec,
        'docMonth': locDocMonth,
        'docMonthRec': locDocMonthRec,
        'docYear': locDocYear,
        'docYearRec': locDocYearRec,
        'bestDay': locDocBestDay,
        'bestWeek': locDocBestWeek,
        'bestMonth': locDocBestMonth,
        'isBlocked': locDocIsBlocked,
        'docYearMap': locDocYearMap,
      });
    }
  } catch (e) {
    print('Error checking/uploading data to Firestore: $e');
  }

  isImageChanged = false;
  //move to the stats screen as the function is done:
}

int calculateScore({pushupController, pullupController}) {
  int score = 0;
  int pushupCount = int.parse((pushupController != '' && pushupController != null) ? pushupController : '0');
  int pullupCount = int.parse((pullupController != '' && pullupController != null) ? pullupController : '0');
  return score = (pushupCount + 3.0 * pullupCount).toInt();
}
