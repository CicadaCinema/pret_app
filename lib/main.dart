import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pret_app/home_screen.dart';
import 'package:pret_app/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

import 'package:uni_links2/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'misc.dart';

// adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "http://flutterbooksample.com/book/g76g76g897/796fg9"

void main() {
  runApp(MyApp());
  //runApp(DeepLinkApp());
}

class MyApp extends StatelessWidget {
  Map<int, Color> pretColour = {
    50: Color.fromRGBO(159, 27, 50, .1),
    100: Color.fromRGBO(159, 27, 50, .2),
    200: Color.fromRGBO(159, 27, 50, .3),
    300: Color.fromRGBO(159, 27, 50, .4),
    400: Color.fromRGBO(159, 27, 50, .5),
    500: Color.fromRGBO(159, 27, 50, .6),
    600: Color.fromRGBO(159, 27, 50, .7),
    700: Color.fromRGBO(159, 27, 50, .8),
    800: Color.fromRGBO(159, 27, 50, .9),
    900: Color.fromRGBO(159, 27, 50, 1),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pret App',
      theme: ThemeData(
          primarySwatch: MaterialColor(0xFF9F1B32, pretColour),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Colors.green, // background
            ),
          )
          //primaryColor: Color(0xFF9F1B32)
          ),
      initialRoute: '/',
      routes: {
        '/': (context) => LauncherScreen(),
        '/qr': (context) => QrScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title!),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DeepLinkApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Shared App Handler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LauncherScreen(),
      },
    );
  }
}

class LauncherScreen extends StatefulWidget {
  @override
  _LauncherScreenState createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  String? _url1;
  String? _url2;
  String? _url3;
  late StreamSubscription _sub;

  Future<void> addCoupon(String couponCode) async {
    print("ahh" + couponCode);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("code", couponCode);
    await showDialogBox("New code read", couponCode, context);
  }

  Future<Null> initUniLinks() async {
    // this function refreshes the _url3 variable with the latest deep link
    // docs at https://pub.dev/packages/uni_links#usage

    // handle cold start
    try {
      String? initialLink = await getInitialLink();
      if (_url1 != initialLink) {
        _url1 = initialLink;
        if (_url3 != _url1) {
          //print("show A");
          await addCoupon(await couponUrlToCode(_url1!));
        }
        _url3 = _url1;
      }
    } on PlatformException {
      print("PlatformException");
    }

    // handle background launch
    _sub = linkStream.listen((String? link) async {
      if (_url2 != link) {
        _url2 = link;
        if (_url3 != _url2) {
          //print("show B");
          await addCoupon(await couponUrlToCode(_url2!));
        }
        _url3 = _url2;
      }
    }, onError: (err) {
      print("Exception: " + err);
    });

    // after everything is complete, refresh the widget
    // setState(() {});
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initUniLinks();

    return MaterialApp(
      title: 'Pret App',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF9F1B32),
          title: Text('Pret App'),
        ),
        body: Center(
          child: Column(
            children: [
              Spacer(),
              /*Text(_url1 ?? "null"),
              Text(_url2 ?? "null"),
              Text(_url3 ?? "null"),
              ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('setState'),
                ),
                onPressed: () async {
                  setState(() {});
                },
              ),*/
              Image.asset(
                "assets/pret_logo.gif",
              ),
              ElevatedButton(
                  // TODO: why do the theme settings I applied above not apply to these two buttons????
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // background
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/qr');
                  },
                  child: Text("QR")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // background
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  child: Text("Settings")),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
