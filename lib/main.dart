import 'package:flutter/material.dart';

import 'detail_page.dart';
import 's3_login.dart';
import 'sftp_detail.dart';
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
        "/dashboard/s3_detail": (BuildContext context) => const DetailPage(),
        "/dashboard/sftp_detail": (BuildContext context) => const SftpDetail(),
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
