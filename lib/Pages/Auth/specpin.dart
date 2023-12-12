import 'package:flutter/material.dart';
import 'package:photouploader/Pages/menu.dart';
import 'package:photouploader/globals.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpecialPinCodePage extends StatefulWidget {
  const SpecialPinCodePage({super.key});

  @override
  State<SpecialPinCodePage> createState() => _SpecialPinCodePageState();
}

class _SpecialPinCodePageState extends State<SpecialPinCodePage> {
  String specPinCode = '';
  final TextEditingController _controller = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    printLog('[SpecialPinCodePage.build()]');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ввод специального пин кода'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pinput(
              length: 4,
              controller: _controller,
              onCompleted: (pin) {
                specPinCode = pin;
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
                      printLog('[storing specpin]');
                      SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      sharedPreferences.setString('specpin', specPinCode);
                      specpin = specPinCode;
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const NormalModePage(),
                      ));
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
