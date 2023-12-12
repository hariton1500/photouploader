import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photouploader/globals.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';

class AskPinCodePage extends StatefulWidget {
  const AskPinCodePage({super.key, required this.onPinCodeEntered});
  final VoidCallback onPinCodeEntered;

  @override
  State<AskPinCodePage> createState() => _AskPinCodePageState();
}

class _AskPinCodePageState extends State<AskPinCodePage> {
  final TextEditingController _controller = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    printLog('[AskPinCodePage.build()]');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ввод пин кода'),
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
                  doLock = false;
                  widget.onPinCodeEntered();
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
