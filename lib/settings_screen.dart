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
        title: Text("Second Screen"),
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
                  if (value == '') {
                    return "Cannot be empty";
                  }/*
                  disabled for testing
                  else if (value!.length != 12) {
                    return "Invalid length";
                  }*/
                  _code = value!;
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Code',
                ),
              ),
              ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Submit'),
                ),
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
