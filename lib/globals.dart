import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

String pin = '', specpin = '';

List<List<String>> notUploaded = [];
String secretKey = '';
bool sessionCheck = false;

final uploader = FlutterUploader();

void backgroundHandler() {
  // Needed so that plugin communication works.
  WidgetsFlutterBinding.ensureInitialized();

  // This uploader instance works within the isolate only.
  FlutterUploader uploader = FlutterUploader();

  // You have now access to:
  uploader.progress.listen((progress) {
    // upload progress
  });
  uploader.result.listen((result) {
    // upload results
  });
}

String appLog = '';

void printLog(Object? object) {
  print(object);
  appLog += '\n$object';
}
