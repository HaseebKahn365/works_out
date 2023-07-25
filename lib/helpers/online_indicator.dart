import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RealTimeIndicator extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _RealTimeIndicatorState createState() => _RealTimeIndicatorState();
}

bool onlineStatus = false;

class _RealTimeIndicatorState extends State<RealTimeIndicator> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Listen to connectivity changes
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        onlineStatus = (result != ConnectivityResult.none);
      });
    });
  }

  @override
  void dispose() {
    // Don't forget to cancel the subscription to avoid memory leaks
    connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: onlineStatus ? 'Online' : 'Offline',
      icon: Icon(
        onlineStatus ? Icons.wifi_rounded : Icons.signal_wifi_off_rounded,
        color: onlineStatus ? Colors.green : Colors.red,
        size: 24,
      ),
      onPressed: () {},
    );
  }
}
