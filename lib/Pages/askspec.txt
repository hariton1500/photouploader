import 'package:flutter/material.dart';
import 'package:photouploader/globals.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AskSpecialPinCodePage extends StatefulWidget {
  const AskSpecialPinCodePage({super.key});

  @override
  State<AskSpecialPinCodePage> createState() => _AskSpecialPinCodePageState();
}

class _AskSpecialPinCodePageState extends State<AskSpecialPinCodePage> {
  final TextEditingController _controller = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ввод специального пин кода'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pinput(
              length: 6,
              controller: _controller,
              onCompleted: (askpin) async {
                if (askpin == specpin) {
                  // деаутентификация
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString('pin', '');
                  // переход на сайт
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Введен неверный код')));
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
