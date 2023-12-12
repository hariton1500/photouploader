import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photouploader/Pages/Auth/login.dart';
import 'package:photouploader/Pages/menu.dart';
import 'package:photouploader/Services/api.dart';
import 'package:photouploader/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Api api = Api();
  pin = sharedPreferences.getString('pin') ?? '';
  printLog('Stored pin: $pin');
  specpin = sharedPreferences.getString('specpin') ?? '';
  printLog('Stored specpin: $specpin');
  secretKey = sharedPreferences.getString('secretKey') ?? '';
  printLog('Stored secretKey: $secretKey');
  if (pin != '' && specpin != '') {
    printLog('Pin and specpin stored, checking session');
    var result = await api.checkSession(secretKey);
    if (result['status'].toString() == 'success') {
      sessionCheck = true;
    } else {
      sessionCheck = false;
    }
  } else {
    printLog('No pin or specpin stored');
  }

  //notUploaded = jsonDecode(sharedPreferences.getString('notUploaded') ?? '[]') as List<List<String>>;
  List temp = jsonDecode(sharedPreferences.getString('notUploaded') ?? '[]');
  //print(temp);
  for (List t in temp) {
    notUploaded.add(t.map((e) => e.toString()).toList());
    //print(t);
  }
  //print(notUploaded);
  applicationSupportDirectory = (await getApplicationSupportDirectory()).path;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo uploader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: (pin == '' || specpin == '' || !sessionCheck)
          ? const LoginPage()
          : const NormalModePage(),
    );
  }
}
