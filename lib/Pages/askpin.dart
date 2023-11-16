import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:photouploader/Pages/askspec.dart';
import 'package:photouploader/Pages/menu.dart';
import 'package:photouploader/globals.dart';
import 'package:pinput/pinput.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AskPinCodePage extends StatefulWidget {
  const AskPinCodePage({super.key});

  @override
  State<AskPinCodePage> createState() => _AskPinCodePageState();
}

class _AskPinCodePageState extends State<AskPinCodePage> {
  final TextEditingController _controller = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      bottomNavigationBar: TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AskSpecialPinCodePage())),
        child: const Text('Ввод специального пин кода'),
      ),*/
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ввод пин кода'),
        //TODO: remove actions for production code
        /*
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.setString('pin', '');
              },
              icon: const Icon(Icons.restore))
        ],*/
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Pinput(
              controller: _controller,
              onCompleted: (askpin) {
                if (askpin == specpin) {
                  //move to some site
                  launchUrl(Uri.parse('https://google.com')).then((value) {
                    if (value) {
                      SystemNavigator.pop();
                    }
                  });
                } else if (askpin == pin) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const NormalModePage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Введен неверный пин код')));
                  _controller.text = '';
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
