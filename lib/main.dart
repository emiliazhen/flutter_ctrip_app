import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';

import 'package:flutter_ctrip/navigator/tab_navigator.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    hideScreen();
  }

  Future<void> hideScreen() async {
    Future.delayed(Duration(milliseconds: 600), () {
      FlutterSplashScreen.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '协Trip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TabNavigator()
    );
  }
}
