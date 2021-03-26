import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class QrScreen extends StatefulWidget {
  @override
  _QrScreenState createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  //String _code = "";
  DateTime? _time_end = null;
  // TODO: update only when timer is visible

  /*void getCode() async {
    final prefs = await SharedPreferences.getInstance();
    _code = prefs.getString("code") ?? "";

    setState(() {});
  }*/

  void handleTimeout() {
    _time_end = null;
  }

  @override
  Widget build(BuildContext context) {
    //getCode();
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
        /*actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],*/
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            _time_end == null
                ? FutureBuilder<SharedPreferences>(
                    future: SharedPreferences.getInstance(),
                    builder: (BuildContext context,
                        AsyncSnapshot<SharedPreferences> snapshot) {
                      String textMessage;
                      if (snapshot.hasData) {
                        String? codeString = snapshot.data!.getString("code");
                        if (codeString == null) {
                          textMessage = "Go to settings to set your code";
                        } else {
                          return QrImage(
                            data: codeString,
                            version: 1,
                            errorCorrectionLevel: 1,
                            size: 300.0,
                          );
                        }
                      } else if (snapshot.hasError) {
                        textMessage = "Could not load QR code.";
                      } else {
                        textMessage = "Loading QR code...";
                      }
                      return Text(textMessage);
                    },
                  )
                /*_code == ""
                    ? Text()
                    : QrImage(
                        data: _code,
                        version: 1,
                        errorCorrectionLevel: 1,
                        size: 300.0,
                      )*/
                : Text("Time left: " +
                    _time_end!.difference(DateTime.now()).toString()),
            ElevatedButton(
              child: Text('Pret'),
              onPressed: () async {
                tz.initializeTimeZones();
                tz.setLocalLocation(tz.getLocation("Europe/London"));

                // different values for debug/release
                Duration duration = Duration(seconds: 15);
                if (kReleaseMode) {
                  duration = Duration(minutes: 30);
                }

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
