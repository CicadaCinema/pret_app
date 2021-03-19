import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _code = "";
  DateTime? _time_end = null;

  void getCode() async {
    final prefs = await SharedPreferences.getInstance();
    _code = prefs.getString("code") ?? "";

    setState(() {});
  }

  void handleTimeout() {
    _time_end = null;
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
            _time_end == null
                ? _code == ""
                    ? Text("Go to settings to set your code")
                    : QrImage(
                        data: _code,
                        version: 1,
                        errorCorrectionLevel: 1,
                        size: 300.0,
                      )
                : Text("Time left: " +
                    _time_end!.difference(DateTime.now()).toString()),
            ElevatedButton(
              child: Text('Pret'),
              onPressed: () async {
                tz.initializeTimeZones();
                tz.setLocalLocation(tz.getLocation("Europe/London"));

                Duration duration = Duration(seconds: 5);


                //////////////////////////////////// GARBAGE START
                _time_end = DateTime.now().add(duration);
                //Timer.periodic(Duration(seconds: 1), (Timer t) => setState((){}));
                Timer(duration, handleTimeout);

                FlutterLocalNotificationsPlugin
                    flutterLocalNotificationsPlugin =
                    FlutterLocalNotificationsPlugin();
                // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
                const AndroidInitializationSettings
                    initializationSettingsAndroid =
                    AndroidInitializationSettings('baseline_coffee_white_24dp');
                //final MacOSInitializationSettings initializationSettingsMacOS =
                //MacOSInitializationSettings();
                //final InitializationSettings initializationSettings =
                //    InitializationSettings(
                //        android: initializationSettingsAndroid);
                flutterLocalNotificationsPlugin.initialize(
                  InitializationSettings(
                      android: initializationSettingsAndroid),
                ); //onSelectNotification: selectNotification

                /////////////////////////////////// GARBAGE END

                await flutterLocalNotificationsPlugin.zonedSchedule(
                    0,
                    'scheduled title',
                    'scheduled body',
                    tz.TZDateTime.now(tz.local).add(duration),
                    const NotificationDetails(
                        android: AndroidNotificationDetails('your channel id',
                            'your channel name', 'your channel description')),
                    androidAllowWhileIdle: true,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime);
              },
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
