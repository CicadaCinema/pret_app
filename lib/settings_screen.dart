import 'package:flutter/material.dart';

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
                    return 'Cannot be empty';
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
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Submit'),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print('Submit');
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
