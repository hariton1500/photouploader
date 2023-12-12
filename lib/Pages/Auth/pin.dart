import 'package:flutter/material.dart';
import 'package:photouploader/Pages/Auth/specpin.dart';
import 'package:photouploader/globals.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  String pinCode = '';
  final TextEditingController _controller = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    printLog('[PinCodePage.build()]');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ввод пин кода'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pinput(
              controller: _controller,
              onCompleted: (pin) {
                pinCode = pin;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      _controller.text = '';
                    },
                    child: const Text('Сбросить')),
                TextButton(
                    onPressed: () async {
                      printLog('[storing pin]');
                      SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      sharedPreferences.setString('pin', pinCode);
                      pin = pinCode;
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const SpecialPinCodePage()));
                    },
                    child: const Text('Сохранить')),
              ],
            )
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
