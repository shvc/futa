import 'package:flutter/material.dart';
import 'package:futa/detail_page.dart';

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
      title: 'futa',
      initialRoute: "/",
      routes: {
        "/": (BuildContext context) => const LoginPage(),
        //"/dashboard": (BuildContext context) =>  DashboardPage(""),
        "/dashboard/detail": (BuildContext context) => const DetailPage(),
      },
    );
  }
}
