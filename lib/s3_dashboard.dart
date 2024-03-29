import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:minio/models.dart' as mmodel;
import 'package:file_picker/file_picker.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as pt;

import 'main.dart';

class S3Dashboard extends StatefulWidget {
  final String bucketName;
  final Minio client;
  late final Stream<mmodel.ListObjectsResult> dataStream;

  S3Dashboard(this.bucketName, this.client, {Key? key}) : super(key: key) {
    dataStream = client.listObjects(bucketName);
  }

  @override
  State createState() => _DashboardState();
}

class _DashboardState extends State<S3Dashboard> {
  bool _isUploadButtonPressed = false;
  @override
  void dispose() {
    super.dispose();
  }

  void logout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
  }

  void upload() async {
    setState(() {
      _isUploadButtonPressed = true;
    });
    try {
      final sms = ScaffoldMessenger.of(context);
      FilePickerResult? pickResult =
          await FilePicker.platform.pickFiles(type: FileType.any);
      if (pickResult == null) {
        debugPrint('User canceled');
        return;
      }

      final filename = pickResult.files.single.path!;
      if (filename == '') {
        debugPrint('no file selected');
        return;
      }

      File local = File(filename);
      final stat = await local.stat();

      final putResult = await widget.client.putObject(widget.bucketName,
          pt.basename(local.path), local.openRead().cast<Uint8List>(),
          size: stat.size);
      debugPrint(
          "upload file:${local.path} key:${local.path.split('/').last} result:$putResult");

      sms.showSnackBar(
        SnackBar(
          content: Text('upload ${local.path}'),
          action: SnackBarAction(label: "OK", onPressed: () => {}),
        ),
      );
    } catch (err) {
      debugPrint(err.toString());
      //debugPrint(stackTrace.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("error"),
            content: Text(err.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isUploadButtonPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.bucketName),
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: SafeArea(
              child: AboutListTile(
                icon: const Icon(Icons.info),
                applicationIcon: const FlutterLogo(),
                applicationVersion: '1.0.0 @2022-11',
                applicationLegalese: '\u{a9} 2022 The Authors',
                aboutBoxChildren: <Widget>[
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        const TextSpan(text: "Home: "),
                        TextSpan(
                          style: const TextStyle(color: Colors.blue),
                          text: 'https://github.com/shvc/futa',
                          recognizer: TapGestureRecognizer(),
                        ),
                        //TextSpan(style: textStyle, text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        endDrawer: Drawer(
          child: ListView(
            //padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: const Text('bucket'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('exit'),
                onTap: () {
                  logout();
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: "upload file",
          onPressed: _isUploadButtonPressed ? null : upload,
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: StreamBuilder(
            stream: widget.dataStream,
            builder: (BuildContext context,
                AsyncSnapshot<mmodel.ListObjectsResult> snapshot) {
              if (snapshot.hasData) {
                final List<mmodel.Object> objects = snapshot.data!.objects;
                return ListView.builder(
                    //shrinkWrap: true,
                    //physics: const NeverScrollableScrollPhysics(),
                    itemCount: objects.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(objects[index].key!),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/dashboard/s3_detail",
                            arguments: objects[index],
                          );
                        },
                      );
                    });
              }
              return const Text("no data");
            },
          ),
        ),
      ),
    );
  }
}
