// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:works_out/auth.dart';
import 'package:works_out/main.dart';
import 'package:works_out/register_page.dart';
import 'package:works_out/typography_screen.dart';

import 'helpers/firebase_uploader.dart';

class LoginPage extends StatefulWidget {
  final ThemeData? themeData;
  final TextTheme? textTheme;

  const LoginPage({Key? key, this.themeData, this.textTheme}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool useMaterial3 = true;
  bool useLightMode = true;
  int colorSelected = 0;
  int screenIndex = 0;

  late ThemeData themeData;
  late TextTheme textTheme;
  late TextStyleExample titleWidget;

  final TextEditingController _field1Controller = TextEditingController();
  final TextEditingController _field2Controller = TextEditingController();
  final FocusNode _field1Focus = FocusNode();
  final FocusNode _field2Focus = FocusNode();

  Future<bool> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(email: _field1Controller.text, password: _field2Controller.text);
      return true;
    } on FirebaseAuthException catch (e) {
      print(e);
      return false;
    }
  }

  @override
  void dispose() {
    _field1Controller.dispose();
    _field2Controller.dispose();
    _field1Focus.dispose();
    _field2Focus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    themeData = widget.themeData ?? ThemeData.light(); // Use default theme if null
    textTheme = widget.textTheme ?? ThemeData.light().textTheme; // Use default text theme if null
    titleWidget = TextStyleExample(
      name: "Account Login",
      style: TextStyle(fontSize: 35),
    );
  }

  ThemeData updateThemes(int colorIndex, bool useMaterial3, bool useLightMode) {
    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: useLightMode ? Brightness.light : Brightness.dark,
    );
  }

  void handleBrightnessChange() {
    setState(() {
      useLightMode = !useLightMode;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
      textTheme = themeData.textTheme;
      titleWidget = TextStyleExample(
        name: "Account Login",
        style: TextStyle(fontSize: 35),
      ); // Add this line
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
          displayColor: themeData.colorScheme.onSurface, // Update this line
          fontSizeFactor: 1.25,
        );

    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: titleWidget,
          actions: [
            IconButton(
              icon: useLightMode ? const Icon(Icons.wb_sunny_outlined) : const Icon(Icons.wb_sunny),
              onPressed: handleBrightnessChange,
              tooltip: "Toggle brightness",
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              SizedBox(
                width: 300,
                height: 250,
                child: Image.asset('assets/images/login.png'),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  controller: _field1Controller,
                  focusNode: _field1Focus,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(_field2Focus);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email for Worksout',
                    prefixIcon: Icon(
                      FluentIcons.mail_12_filled,
                      size: 30,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30.0, 12.0, 30.0, 0),
                child: TextField(
                  controller: _field2Controller,
                  focusNode: _field2Focus,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    _field2Focus.unfocus();
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                    prefixIcon: Icon(
                      FluentIcons.lock_closed_12_filled,
                      size: 25,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  bool isAccountCreated = await signInWithEmailAndPassword();
                  if (isAccountCreated) {
                    await showlogSuccessMessage('Account Login successfully \n We are now taking you to home screen');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => WorksOut()),
                      (route) => false,
                    );
                  } else {
                    showlogErrorMessage(context, 'Account login failed');
                  }
                },
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('If you wanna create a Worksout Account then'),
                  TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegistrationScreen(themeData: themeData, textTheme: textTheme)),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Register',
                      )),
                ],
              ),
              Container(
                width: 200,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Handle the onTap event here
                        await signInWithGoogle();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => WorksOut()),
                            (route) => false,
                          );
                        }
                      },
                      child: Image.asset(
                        'assets/images/google.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  //banner for success:

  Future<void> showlogSuccessMessage(String message) async {
    submitFormOnSave();
    final completer = Completer<void>();
    Timer(Duration(seconds: 2, milliseconds: 500), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      completer.complete(); // Signal completion after hiding the banner.
    });
    final banner = MaterialBanner(
      content: Text(
        message + '\nNow go to login screen',
        style: TextStyle(color: Colors.green),
      ),
      actions: [
        TextButton(
          child: Text('Ok'),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            completer.complete(); // Signal completion after the 'Ok' button is pressed.
          },
        ),
      ],
    );

    ScaffoldMessenger.of(context).showMaterialBanner(banner);
    return completer.future; // Return the future for awaiting the completion.
  }
}

//banner for error:

void showlogErrorMessage(BuildContext context, String message) {
  Timer(Duration(seconds: 2, milliseconds: 500), () {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  });
  final banner = MaterialBanner(
    content: Text(
      '$message\nCheck your internet connection \nor try another email',
      style: TextStyle(color: Colors.red),
    ),
    actions: [
      TextButton(
        child: Text('Ok'),
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        },
      ),
    ],
  );

  ScaffoldMessenger.of(context).showMaterialBanner(banner);
}
