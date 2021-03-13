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

  @override
  Widget build(BuildContext context) {
    getCode();
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            QrImage(
              data: _code,
              version: 1,
              errorCorrectionLevel: 1,
              size: 300.0,
            ),
            ElevatedButton(
              child: Text('Options'),
              onPressed: () {
                // Navigate to the second screen when tapped.
                // Navigate to the second screen using a named route.
                Navigator.pushNamed(context, '/second');
              },
            ),
          ],
        ),
      ),
    );
  }
}
