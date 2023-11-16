import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photouploader/Pages/askpin.dart';
import 'package:photouploader/Pages/login.dart';
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
  secretKey = sharedPreferences.getString('secretKey') ?? '';
  Api api = Api();
  var result = await api.checkSession(secretKey);
  if (result['status'].toString() == 'success') {
    sessionCheck = true;
  }
  pin = sharedPreferences.getString('pin') ?? '';
  specpin = sharedPreferences.getString('specpin') ?? '';
  //notUploaded = jsonDecode(sharedPreferences.getString('notUploaded') ?? '[]') as List<List<String>>;
  List temp = jsonDecode(sharedPreferences.getString('notUploaded') ?? '[]');
  //print(temp);
  for (List t in temp) {
    notUploaded.add(t.map((e) => e.toString()).toList());
    //print(t);
  }
  print(notUploaded);
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
          : const AskPinCodePage(),
    );
  }
}
