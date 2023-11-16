import 'package:flutter/material.dart';
import 'package:photouploader/Pages/pin.dart';
import 'package:photouploader/Services/api.dart';
import 'package:photouploader/globals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Авторизация'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onChanged: (text) {
                  username = text;
                },
                decoration: const InputDecoration(
                  hintText: 'Логин',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onChanged: (text) {
                  password = text;
                },
                decoration: const InputDecoration(
                  hintText: 'Пароль',
                ),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextButton(
                onPressed: () async {
                  // проверку ввода
                  if (username == '') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Логин не может быть пустым!')));
                  }
                  if (password == '') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Пароль не может быть пустым!')));
                  }
                  if (username != '' && password != '') {
                    // авторизацию по API-запросу к back-end серверу
                    Api api = Api();
                    var result = await api.authenticate(username, password);
                    print(result);
                    if (result['status'].toString() == 'success') {
                      secretKey = result['api_key'];
                      api.saveSecretKey(secretKey.toString());
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const PinCodePage()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ошибка авторизации')));
                    }
                    // обработку ответа
                  }
                },
                child: const Text('Войти'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
