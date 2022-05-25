import 'package:flutter/material.dart';

import 'detail_page.dart';
import 's3_login.dart';
import 'sftp_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'futa',
      initialRoute: "/",
      routes: {
        //"/": (BuildContext context) => LoginPage(),
        //"/dashboard": (BuildContext context) =>  DashboardPage(""),
        "/dashboard/detail": (BuildContext context) => const DetailPage(),
      },
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'S3'),
                Tab(text: 'sftp'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              S3LoginPage(),
              SftpLoginPage(),
            ],
          ),
        ),
      ),
    );
  }
}
