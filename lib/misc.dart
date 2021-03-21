import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<String> couponUrlToCode(String url) async {
  // download coupon
  var httpClient = new HttpClient();
  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();
  var bytes = await consolidateHttpClientResponseBytes(response);

  // extract zip archive
  final archive = ZipDecoder().decodeBytes(bytes);

  // search for file containing pass
  for (final file in archive) {
    final filename = file.name;
    if (file.isFile && file.name == "pass.json") {
      // extract json from file
      String data = utf8.decode(file.content as List<int>);
      Map<String, dynamic> code = jsonDecode(data);

      // extract code from json
      return code["barcode"]["message"];
    }
  }

  // in case of some error return blank string
  return "";
}

Future<void> showDialogBox(String title, String message, BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}