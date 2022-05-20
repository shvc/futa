import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:minio/models.dart' as mmodel;
import 'package:file_picker/file_picker.dart';
import 'package:minio/minio.dart';

import 'detail_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final String bucketName;
  final Minio client;
  late final Stream<mmodel.ListObjectsResult> dataStream;

  DashboardPage(this.bucketName, this.client, {Key? key}) : super(key: key) {
    dataStream = client.listObjects(bucketName);
  }

  @override
  State createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  bool _isUploadButtonPressed = false;
  @override
  void dispose() {
    super.dispose();
  }

  void logout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
          local.path.split('/').last, local.openRead().cast<Uint8List>(),
          size: stat.size);
      debugPrint(
          "upload file:${local.path} key:${local.path.split('/').last} result:$putResult");

      sms.showSnackBar(
        SnackBar(
          content: Text('upload ${local.path}'),
          action: SnackBarAction(label: "OK", onPressed: () => {}),
        ),
      );
    } catch (err, stackTrace) {
      debugPrint(err.toString());
      debugPrint(stackTrace.toString());
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
          child: ListView(
            //padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: const Text('preference'),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailPage(),
                              // Pass the arguments as part of the RouteSettings. The
                              // DetailScreen reads the arguments from these settings.
                              settings: RouteSettings(
                                arguments: objects[index],
                              ),
                            ),
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
