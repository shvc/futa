import 'dart:io';

import 'package:flutter/material.dart';
import 'package:minio/models.dart' as mmodel;
import 'package:file_picker/file_picker.dart';

import 'detail_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final String bucketName;
  final Stream<mmodel.ListObjectsResult> dataStream;

  const DashboardPage(this.bucketName, this.dataStream, {Key? key})
      : super(key: key);

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
      File local = File(pickResult.files.single.path!);
      debugPrint("upload file: ${local.path}");

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
