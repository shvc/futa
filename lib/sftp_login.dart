import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:futa/sftp_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class SftpLoginPage extends StatefulWidget {
  const SftpLoginPage({Key? key}) : super(key: key);

  @override
  State createState() => _SftpLoginPageState();
}

class _SftpLoginPageState extends State<SftpLoginPage> {
  bool _isLoginButtonPressed = false;

  final sftpServerControler = TextEditingController();
  final sftpUserNameControler = TextEditingController();
  final sftpUserPasswdControler = TextEditingController();
  final sftpRemoteDirControler = TextEditingController();

  final sftpServerPrefsName = 'sftp_server_name';
  final sftpUserNamePrefsName = 'sftp_user_name';
  final sftpPasswordPrefsName = 'sftp_password_name';
  final sftpRemoteDirPrefsName = 'sftp_remote_dir_name';

  void loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sftpServerControler.text = prefs.getString(sftpServerPrefsName) ?? '';
      sftpUserNameControler.text = prefs.getString(sftpUserNamePrefsName) ?? '';
      sftpUserPasswdControler.text =
          prefs.getString(sftpPasswordPrefsName) ?? '';
      sftpRemoteDirControler.text =
          prefs.getString(sftpRemoteDirPrefsName) ?? '';
    });
  }

  void savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sftpServerPrefsName, sftpServerControler.text);
    await prefs.setString(sftpUserNamePrefsName, sftpUserNameControler.text);
    await prefs.setString(sftpPasswordPrefsName, sftpUserPasswdControler.text);
    await prefs.setString(sftpRemoteDirPrefsName, sftpRemoteDirControler.text);
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

      final client = SSHClient(
        await SSHSocket.connect(sftpServerControler.text, 22),
        username: sftpUserNameControler.text,
        onPasswordRequest: () => sftpUserPasswdControler.text,
      );
      final sftp = await client.sftp();
      savePrefs();

      nav.pushReplacement(MaterialPageRoute(builder: (context) {
        return SftpDashboard(sftpRemoteDirControler.text, sftp);
      }));
    } catch (err, stackTrace) {
      debugPrint('dir:${sftpRemoteDirControler.text}, err:${err.toString()}');
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
    final hero = Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 15),
      child: Hero(
        tag: 'sftp',
        child: CircleAvatar(
          radius: 44.0,
          backgroundColor: Colors.transparent,
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );

    final serverField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        autofocus: true,
        controller: sftpServerControler,
        decoration: InputDecoration(
          labelText: "Server",
          hintText: 'address:port',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 1,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        validator: (v) {
          return v!.trim().isNotEmpty
              ? null
              : "Server address can not be empty";
        },
      ),
    );

    final userNameField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        autofocus: true,
        controller: sftpUserNameControler,
        decoration: InputDecoration(
          labelText: "User Name",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        validator: (v) {
          return v!.trim().length > 1 ? null : "User Name is too short";
        },
      ),
    );

    final userPasswordField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: sftpUserPasswdControler,
        decoration: InputDecoration(
          labelText: "User Password",
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
          return v!.trim().length > 1 ? null : "User Password is too short";
        },
      ),
    );

    final remoteDirField = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: sftpRemoteDirControler,
        decoration: InputDecoration(
          labelText: "Remote Dir",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        validator: (v) {
          return v!.trim().isNotEmpty ? null : "Remote Dir is too short";
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
                    serverField,
                    userNameField,
                    userPasswordField,
                    remoteDirField,
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
