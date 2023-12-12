import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

String pin = '', specpin = '';
String? applicationSupportDirectory;

List<List<String>> notUploaded = [];
Map<int, List<File>> get notUploadedFilesMap {
  Map<int, List<File>> result = {};
  for (var group in notUploaded) {
    result[int.parse(group[0])] = (jsonDecode(group[2]) as List)
        .map(
            (e) => File('$applicationSupportDirectory/${group[1]}-${e[0]}.jpg'))
        .toList();
  }
  return {};
}

String secretKey = '';
bool sessionCheck = false;
bool doLock = true;
//DateTime lastAppLifecycleStateTime = DateTime.now();
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

String get appState => sessionCheck ? 'logged in' : 'logged out';
