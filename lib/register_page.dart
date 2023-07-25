// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:works_out/auth.dart';
import 'package:works_out/login_page.dart';
import 'package:works_out/typography_screen.dart';

import 'main.dart';

class RegistrationScreen extends StatefulWidget {
  final ThemeData themeData;
  final TextTheme textTheme;

  const RegistrationScreen({Key? key, required this.themeData, required this.textTheme}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool useMaterial3 = true;
  bool useLightMode = true;
  int colorSelected = 0;
  int screenIndex = 0;

  late ThemeData themeData;
  late TextTheme textTheme;
  late TextStyleExample titleWidget;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password2 = TextEditingController();
  final FocusNode _field1Focus = FocusNode();
  final FocusNode _field2Focus = FocusNode();
  final FocusNode _field3Focus = FocusNode();

  Future<bool> createUserWithEmailAndPassword({required String email, required String password}) async {
    try {
      await Auth().createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print('error\nerror\nerror $e');
      return false;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _field1Focus.dispose();
    _field2Focus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    themeData = widget.themeData;
    textTheme = widget.textTheme;

    titleWidget = TextStyleExample(
      name: "Registration",
      style: TextStyle(fontSize: 35),
    ); // Add this line
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
        name: "Registration",
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
        key: _scaffoldKey,
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

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  controller: _email,
                  focusNode: _field1Focus,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(_field2Focus);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Create Worksout email',
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
                  keyboardType: TextInputType.emailAddress,
                  controller: _password,
                  focusNode: _field2Focus,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(_field3Focus);
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
              Container(
                margin: const EdgeInsets.fromLTRB(30.0, 12.0, 30.0, 0),
                child: TextField(
                  obscureText: true,
                  controller: _password2,
                  focusNode: _field3Focus,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    _field3Focus.unfocus();
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Confirm Password',
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
                  final email = _email.text;
                  final password = _password.text;

                  if (_password.text.length < 6) {
                    _showWeakPasswordBanner(context);
                  } else if (_password2.text != _password.text) {
                    _showPasswordMismatchBanner(context);
                  } else if (_password2.text == _password.text) {
                    bool isAccountCreated = await createUserWithEmailAndPassword(email: email, password: password);
                    if (isAccountCreated) {
                      showSuccessMessage(context, 'Account created successfully');
                    } else {
                      showErrorMessage(context, 'Account creation failed');
                    }
                  }
                },
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Wanna go back to login screen?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage(themeData: themeData, textTheme: textTheme)),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Login',
                    ),
                  ),
                ],
              ),

              //GOOGLE  SIGN IN BUTTON option on registration page:
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
                    //adding error text widget:
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//banner for confirm password:

void _showPasswordMismatchBanner(BuildContext context) {
  Timer(Duration(seconds: 2, milliseconds: 500), () {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  });
  final banner = MaterialBanner(
    content: Text('Passwords don\'t match. Please confirm your password.'),
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

//banner for weak password:

void _showWeakPasswordBanner(BuildContext context) {
  Timer(Duration(seconds: 2, milliseconds: 500), () {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  });
  final banner = MaterialBanner(
    content: Text('Weak password! Try a stronger password'),
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

//banner for error:

void showErrorMessage(BuildContext context, String message) {
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

//banner for success:

void showSuccessMessage(BuildContext context, String message) {
  Timer(Duration(seconds: 2, milliseconds: 500), () {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  });
  final banner = MaterialBanner(
    content: Text(
      message + '\nNow go to login screeen',
      style: TextStyle(color: Colors.green),
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
