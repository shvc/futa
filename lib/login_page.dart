import 'package:flutter/material.dart';
import 'package:minio/minio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginButtonPressed = false;

  final endpointControler = TextEditingController();
  final regionControler = TextEditingController();
  final accessKeyControler = TextEditingController();
  final secretKeyControler = TextEditingController();
  final bucketNameControler = TextEditingController();

  final endpointPrefsName = 'endpoint_name';
  final regionPrefsName = 'region_name';
  final accessKeyPrefsName = 'access_key_name';
  final secretKeyPrefsName = 'secret_key_name';
  final bucketPrefsName = 'bucket_name';

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
      debugPrint('ak: ' + accessKeyControler.text);
      debugPrint('sk: ' + secretKeyControler.text);

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
        debugPrint('bucket not exists: ' + bucketNameControler.text);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("alter"),
              content: Text("bucket not exists: " + bucketNameControler.text),
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
      var objs = minio.listObjects(bucketNameControler.text);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return DashboardPage(bucketNameControler.text, objs);
      }));
    } catch (err, stackTrace) {
      debugPrint('bucket:${bucketNameControler.text}, err:${err.toString()}');
      debugPrint('trace:${stackTrace.toString()}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("alter"),
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

  @override
  Widget build(BuildContext context) {
    final logo = Padding(
      padding: const EdgeInsets.all(20),
      child: Hero(
        tag: 'hero',
        child: CircleAvatar(
          radius: 44.0,
          backgroundColor: Colors.transparent,
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );

    final inputEndpoint = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        keyboardType: TextInputType.url,
        controller: endpointControler,
        decoration: InputDecoration(
            labelText: "Endpoint",
            hintText: 'http://address:port',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(50.0))),
      ),
    );

    final inputRegion = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: regionControler,
        decoration: InputDecoration(
            labelText: "Region",
            hintText: 'cn-north-1',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(50.0))),
      ),
    );

    final inputAccessKey = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: accessKeyControler,
        decoration: InputDecoration(
            labelText: "Access Key",
            //hintText: 'Access Key',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(50.0))),
      ),
    );

    final inputSecretKey = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        obscureText: true,
        controller: secretKeyControler,
        decoration: InputDecoration(
          labelText: "Secret Key",
          //hintText: 'Secret Key',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );

    final inputBucketName = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: bucketNameControler,
        decoration: InputDecoration(
          labelText: "Bucket Name",
          //hintText: 'Bucket Name',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );

    final buttonLogin = Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: ButtonTheme(
        height: 56,
        child: ElevatedButton(
          child: const Text('Login',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          onPressed: _isLoginButtonPressed ? null : login,
        ),
      ),
    );

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              logo,
              inputEndpoint,
              inputRegion,
              inputAccessKey,
              inputSecretKey,
              inputBucketName,
              buttonLogin,
            ],
          ),
        ),
      ),
    );
  }
}
