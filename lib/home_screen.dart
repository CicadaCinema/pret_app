import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _code = "";

  void getCode() async {
    final prefs = await SharedPreferences.getInstance();
    _code = prefs.getString("code") ?? "";
    setState(() {});
  }

  void handleTimeout() {
    print("timer");
  }

  @override
  Widget build(BuildContext context) {
    getCode();
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/second');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            _code == ""
                ? Text("No code")
                : QrImage(
                    data: _code,
                    version: 1,
                    errorCorrectionLevel: 1,
                    size: 300.0,
                  ),
            ElevatedButton(
              child: Text('Start Timer'),
              onPressed: () {
                Timer(Duration(seconds: 5), handleTimeout);
              },
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
