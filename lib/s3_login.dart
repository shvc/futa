import 'dart:io';

import 'package:flutter/material.dart';
import 'package:minio/minio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class S3LoginPage extends StatefulWidget {
  const S3LoginPage({Key? key}) : super(key: key);

  @override
  State createState() => _S3LoginPageState();
}

class _S3LoginPageState extends State<S3LoginPage> {
  bool _isLoginButtonPressed = false;

  final endpointControler = TextEditingController();
  final regionControler = TextEditingController();
  final accessKeyControler = TextEditingController();
  final secretKeyControler = TextEditingController();
  final bucketNameControler = TextEditingController();

  final endpointPrefsName = 's3_endpoint_name';
  final regionPrefsName = 's3_region_name';
  final accessKeyPrefsName = 's3_access_key_name';
  final secretKeyPrefsName = 's3_secret_key_name';
  final bucketPrefsName = 's3_bucket_name';

  void loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      endpointControler.text = prefs.getString(endpointPrefsName) ?? '';
      regionControler.text = prefs.getString(regionPrefsName) ?? '';
      accessKeyControler.text = prefs.getString(accessKeyPrefsName) ?? '';
      secretKeyControler.text = prefs.getString(secretKeyPrefsName) ?? '';
      bucketNameControler.text = prefs.getString(bucketPrefsName) ?? '';
    });
  }

  void savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(endpointPrefsName, endpointControler.text);
    await prefs.setString(regionPrefsName, regionControler.text);
    await prefs.setString(accessKeyPrefsName, accessKeyControler.text);
    await prefs.setString(secretKeyPrefsName, secretKeyControler.text);
    await prefs.setString(bucketPrefsName, bucketNameControler.text);
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  @override
  void dispose() {
    // endpointControler.dispose();
    // regionControler.dispose();
    // accessKeyControler.dispose();
    // secretKeyControler.dispose();
    // bucketNameControler.dispose();
    super.dispose();
  }

  login() async {
    setState(() {
      _isLoginButtonPressed = true;
    });
    try {
      var nav = Navigator.of(context);
      int? port;
      bool useSSL = false;
      var endpoint = Uri.parse(endpointControler.text);
      if (endpoint.hasPort) {
        port = endpoint.port;
      }
      if (endpoint.isScheme('https')) {
        useSSL = true;
      }
      debugPrint('endpoint: ${endpointControler.text}');
      debugPrint('host: ${endpoint.host} port: $port ssl: $useSSL');
      debugPrint('ak: ${accessKeyControler.text}');
      debugPrint('sk: ${secretKeyControler.text}');

      final minio = Minio(
        endPoint: endpoint.host,
        accessKey: accessKeyControler.text,
        secretKey: secretKeyControler.text,
        port: port,
        region: regionControler.text,
        useSSL: useSSL,
        enableTrace: true,
      );

      var exists = await minio.bucketExists(bucketNameControler.text);
      if (!exists) {
        debugPrint('bucket ${bucketNameControler.text} not exists');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("alter"),
              content: Text('bucket ${bucketNameControler.text} not exists'),
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
        return;
      }
      savePrefs();

      nav.pushReplacement(MaterialPageRoute(builder: (context) {
        return DashboardPage(bucketNameControler.text, minio);
      }));
    } catch (err, stackTrace) {
      debugPrint('bucket:${bucketNameControler.text}, err:${err.toString()}');
      debugPrint('trace:${stackTrace.toString()}');
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
        _isLoginButtonPressed = false;
      });
    }
  }

  final GlobalKey _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const hero = Padding(
      padding: EdgeInsets.only(top: 0, bottom: 0),
      child: Hero(
        tag: 's3',
        child: Icon(Icons.share),
      ),
    );

    final endpointField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        autofocus: true,
        controller: endpointControler,
        decoration: InputDecoration(
          labelText: "Endpoint",
          hintText: 'http://address:port',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 1,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        validator: (v) {
          return v!.trim().isNotEmpty ? null : "Endpoint URL can not be empty";
        },
      ),
    );

    final regionField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        autofocus: true,
        controller: regionControler,
        decoration: InputDecoration(
          labelText: "Region",
          hintText: 'cn-north-1',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        validator: (v) {
          return null;
        },
      ),
    );

    final accessKeyField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        autofocus: true,
        controller: accessKeyControler,
        decoration: InputDecoration(
          labelText: "Access Key",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        validator: (v) {
          return v!.trim().length > 1 ? null : "Access Key is too short";
        },
      ),
    );

    final secretKeyField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: secretKeyControler,
        decoration: InputDecoration(
          labelText: "Secret Key",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        obscureText: true,
        validator: (v) {
          return v!.trim().length > 1 ? null : "Secret Key is too short";
        },
      ),
    );

    final bucketNameField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: bucketNameControler,
        decoration: InputDecoration(
          labelText: "Bucket Name",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        validator: (v) {
          return v!.trim().length > 2 ? null : "Bucket Name is too short";
        },
      ),
    );

    final enterField = Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoginButtonPressed
                  ? null
                  : () {
                      if (!(_formKey.currentState as FormState).validate()) {
                        return;
                      }
                      login();
                    },
              focusNode: FocusNode(),
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text("Enter"),
              ),
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Scaffold(
        persistentFooterButtons: [
          Text(Platform.operatingSystem),
          Text(Platform.operatingSystemVersion)
        ],
        body: SingleChildScrollView(
          child: Column(
            children: [
              hero,
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: <Widget>[
                    endpointField,
                    regionField,
                    accessKeyField,
                    secretKeyField,
                    bucketNameField,
                    enterField,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
