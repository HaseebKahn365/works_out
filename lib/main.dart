// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:works_out/helpers/online_indicator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'helpers/firebase_uploader.dart';
import 'stats_screen.dart';
import 'component_screen.dart';
import 'login_page.dart';
import 'typography_screen.dart';
import 'auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(WorksOut());
}

File? imageFile;
File? userImageFile; //it will be uploaded to the firestore if not null.

Future<void> signInWithGoogle() async {
  //create an instance of the firebase auth and gooogle signin
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  //Triger the google signin flow
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
  //Create a new credentials
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  //Signin the user with the credentials
  final UserCredential userCredential = await auth.signInWithCredential(credential);

  user = userCredential.user; //this is the user that is signed in
}

//implementing sign out for google user:

Future<bool> googleLogOut() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    return true;
  } on Exception catch (e) {
    print(e);
    return false;
  }
}

Future<void> signOut() async {
  await Auth().signOut();
}

class WorksOut extends StatefulWidget {
  WorksOut({super.key});

  @override
  State<WorksOut> createState() => _WorksOutState();
}

bool isImageChanged = false; //it is for checking if image should be uploaded.
String? userNameController;

// NavigationRail shows if the screen width is greater or equal to
// screenWidthThreshold; otherwise, NavigationBar is used for navigation.
const double narrowScreenWidthThreshold = 450;

const Color m3BaseColor = Color(0xff6750a4);
const List<Color> colorOptions = [
  m3BaseColor,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
  Colors.black,
  Colors.black
];
const List<String> colorText = <String>[
  "M3 Baseline",
  "Blue",
  "Teal",
  "Green",
  "Yellow",
  "Orange",
  "Pink",
  "  Logout",
  "Settings",
];
final FirebaseAuth auth = FirebaseAuth.instance;

User? user;

class _WorksOutState extends State<WorksOut> {
  bool useMaterial3 = true;
  bool useLightMode = true;
  int colorSelected = 0;
  int screenIndex = 0;

  late ThemeData themeData;
  TextEditingController changeNameController = TextEditingController();

  void _showLogoutConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Are you sure you want to log out?'),
        duration: Duration(seconds: 2, milliseconds: 500),
        action: SnackBarAction(
          label: 'Logout',
          onPressed: () async {
            // Implement the logout functionality here
            //If its a google user then i will use the SignOut() for google user:
            bool isGoogleLoggedOut = await googleLogOut();

            if (isGoogleLoggedOut) {
              print('Google user logged out');
              userImageFile = null;

              //Making all the local variables null before the user is logged out:
              locDocIsHaseeb = null;
              locDocUserImage = null;
              locDocUserName = 'Anonymous';
              locDocEmail = null;
              locDocPassword = null;
              locDocPushCount = 0;
              locDocPullCount = 0;
              locDocDayToday = 0;
              locDocDayRec = 0;
              locDocWeek = 0;
              locDocWeekRec = 0;
              locDocMonth = 0;
              locDocMonthRec = 0;
              locDocYear = 0;
              locDocYearRec = 0;
              locDocBestDay = 0;
              locDocBestWeek = 0;
              locDocBestMonth = 0;
              locDocIsBlocked = false;
              locDocYearMap = {};

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(themeData: themeData)),
                  (route) => false,
                );
              }
            } else {
              print('Google user not logged out');
            }

            signOut();
            userImageFile = null;

            //making all the local variables null before the user signsout:
            locDocIsHaseeb = null;
            locDocUserImage = null;
            locDocUserName = 'Anonymous';
            locDocEmail = null;
            locDocPassword = null;
            locDocPushCount = 0;
            locDocPullCount = 0;
            locDocDayToday = 0;
            locDocDayRec = 0;
            locDocWeek = 0;
            locDocWeekRec = 0;
            locDocMonth = 0;
            locDocMonthRec = 0;
            locDocYear = 0;
            locDocYearRec = 0;
            locDocBestDay = 0;
            locDocBestWeek = 0;
            locDocBestMonth = 0;
            locDocIsBlocked = false;
            locDocYearMap = {};
            //go to login page:
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage(themeData: themeData)),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  initState() {
    super.initState();
    user = Auth().currentUser;

    themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
  }

  ThemeData updateThemes(int colorIndex, bool useMaterial3, bool useLightMode) {
    return ThemeData(
        colorSchemeSeed: colorOptions[colorSelected],
        useMaterial3: useMaterial3,
        brightness: useLightMode ? Brightness.light : Brightness.dark);
  }

  var openedScreen;
  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
      openedScreen = selectedScreen;
    });
  }

  void handleBrightnessChange() {
    setState(() {
      useLightMode = !useLightMode;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    });
  }

  void handleColorSelect(BuildContext context, int value) {
    setState(() {
      if (value == 7) {
        _showLogoutConfirmation(context);
      } else if (value == 8) {
        showDialog(
          context: context,
          builder: (context) {
            File? currentImageFile = imageFile; // Create a local variable to store the current image file

            return AlertDialog(
              title: Text(
                'Settings',
                style: TextStyle(fontSize: 20),
              ),
              content: SingleChildScrollView(
                reverse: true,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: themeData.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: (userImageFile != null)
                                ? Container(
                                    height: 150,
                                    width: 150,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Stack(
                                        children: [
                                          Image.file(
                                            userImageFile!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  bottomRight: Radius.circular(20),
                                                ),
                                              ),
                                              child: Icon(
                                                FluentIcons.camera_add_48_regular,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : (locDocUserImage != null)
                                    ? Container(
                                        height: 150,
                                        width: 150,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: CachedNetworkImage(
                                            imageUrl: locDocUserImage!,
                                            progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: CircularProgressIndicator(value: downloadProgress.progress),
                                            ),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        FluentIcons.camera_add_48_regular,
                                        size: 40,
                                      ),
                          ),
                          onTap: () async {
                            XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              CroppedFile? croppedImage = await ImageCropper().cropImage(
                                sourcePath: pickedFile.path,
                                maxHeight: 1080,
                                maxWidth: 1080,
                              );
                              if (croppedImage != null) {
                                setState(() {
                                  currentImageFile = File(croppedImage.path); // Update the currentImageFile
                                  userImageFile = currentImageFile;
                                });
                              }
                              isImageChanged = true;
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        TextField(
                          maxLength: 20, // Limit the length to 20 characters
                          controller: changeNameController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            prefixIcon: Icon(
                              FluentIcons.edit_20_filled,
                              color: themeData.hintColor,
                              size: 25,
                            ),
                            hintText: 'Change Name',
                            helperText: 'Current : $locDocUserName',
                            border: OutlineInputBorder(),
                          ),
                          buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) {
                            currentLength ??= 0;
                            return Text('${(20 - currentLength)} left', style: TextStyle(fontSize: 11));
                          },
                          onChanged: (String value) {
                            setState(() {
                              // Update the state when the text field value changes
                              if (changeNameController.text != '') {
                                userNameController = changeNameController.text;
                              }
                            }); //setState
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    isImageChanged = false;
                    changeNameController.clear();

                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Foreground color
                      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                      // Background color
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                    onPressed: () {
                      //TODO: request change in the firestore document AWAIT
                      //also upload the changenameController if its not ''
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        colorSelected = value;
        themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
      }
    });
  }

  Widget createScreenFor(int screenIndex, bool showNavBarExample) {
    switch (screenIndex) {
      case 0:
        return ComponentScreen(
          showNavBottomBar: showNavBarExample,
          textTheme: Theme.of(context).textTheme,
        );
      case 1:
        return const StatsScreen();
      case 2:
        return const TypographyScreen();
      default:
        return ComponentScreen(
          showNavBottomBar: showNavBarExample,
          textTheme: Theme.of(context).textTheme,
        );
    }
  }

  Text? appBarText() {
    if (openedScreen == 0) {
      return const Text(
        'Update / Add',
        style: TextStyle(fontSize: 20),
      );
    } else if (openedScreen == 1) {
      return const Text(
        'Statistics',
        style: TextStyle(fontSize: 20),
      );
    } else if (openedScreen == 2) {
      return const Text(
        'Top Scorers',
        style: TextStyle(fontSize: 20),
      );
    } else {
      return const Text(
        'Update / Add',
        style: TextStyle(fontSize: 20),
      );
    }
  }

  PreferredSizeWidget createAppBar() {
    return AppBar(
      title: appBarText(),
      actions: [
        IconButton(
          tooltip: ('(${onlineStatus == true ? 'Online' : 'Offline'})'),
          icon: RealTimeIndicator(),
          onPressed: () {},
        ),
        IconButton(
          icon: useLightMode ? const Icon(Icons.wb_sunny_outlined) : const Icon(Icons.wb_sunny),
          onPressed: handleBrightnessChange,
          tooltip: "Toggle brightness",
        ),
        Builder(builder: (context) {
          return PopupMenuButton(
            icon: const Icon(FluentIcons.line_horizontal_3_20_filled),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (context) {
              return List.generate(colorText.length, (index) {
                return PopupMenuItem(
                    value: index,
                    child: Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            (index == 7)
                                ? Icons.logout
                                : (index == 8 && index == colorSelected)
                                    ? FluentIcons.settings_28_filled
                                    : (index == 8)
                                        ? FluentIcons.settings_16_regular
                                        : index == colorSelected
                                            ? FluentIcons.checkmark_square_24_filled
                                            : Icons.color_lens_outlined,
                            color: (index == 8 || index == 7) ? themeData.hintColor : colorOptions[index],
                            size: (index == 7) ? 26 : 30,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: (index == 7)
                                ? Column(
                                    children: [
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      Text(colorText[index]),
                                    ],
                                  )
                                : (index == 8)
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          Text(colorText[index]),
                                        ],
                                      )
                                    : Text(colorText[index])),
                        (index == 6)
                            ? const Column(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Divider(),
                                  SizedBox()
                                ],
                              )
                            : const SizedBox(height: 0),
                      ],
                    ));
              });
            },
            onSelected: (value) => handleColorSelect(context, value),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workout Manager',
      themeMode: useLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: themeData,
      home: (user == null)
          ? LoginPage(themeData: themeData)
          : LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < narrowScreenWidthThreshold) {
                return Scaffold(
                  appBar: createAppBar(),
                  body: Row(children: <Widget>[
                    createScreenFor(screenIndex, false),
                  ]),
                  bottomNavigationBar: NavigationBars(
                    onSelectItem: handleScreenChanged,
                    selectedIndex: screenIndex,
                    isExampleBar: false,
                  ),
                );
              } else {
                return Scaffold(
                  appBar: createAppBar(),
                  body: SafeArea(
                    bottom: false,
                    top: false,
                    child: Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child:
                                NavigationRailSection(onSelectItem: handleScreenChanged, selectedIndex: screenIndex)),
                        const VerticalDivider(thickness: 1, width: 1),
                        createScreenFor(screenIndex, true),
                      ],
                    ),
                  ),
                );
              }
            }),
    );
  }
}
