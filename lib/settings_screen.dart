import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Spacer(),
              TextFormField(
                validator: (value) {
                  // only for release:
                  if (kReleaseMode) {
                    if (value == '') {
                      return "Cannot be empty";
                    } else if (value!.length != 12) {
                      return "Invalid length";
                    }
                  }

                  _code = value!;
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Code',
                ),
              ),
              ElevatedButton(
                child: Text('Submit'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("code", _code);
                    Navigator.pop(context);
                  }
                },
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
