import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

class SftpDetail extends StatelessWidget {
  const SftpDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obj = ModalRoute.of(context)!.settings.arguments as SftpName;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('name : ${obj.longname}'),
          ],
        ),
      ),
    );
  }
}
