import 'dart:io';

import 'package:flutter/material.dart';

import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app title',
      home: Scaffold(
        persistentFooterButtons: [
          Text(Platform.operatingSystem),
          Text(Platform.operatingSystemVersion)
        ],
        body: const LoginPage(),
      ),
    );
  }
}
