import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: MyWebView(),
    );
  }
}

class MyWebView extends StatefulWidget {
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final webViewController = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedLogin = prefs.getString('login') ?? '';
    String savedPassword = prefs.getString('password') ?? '';

    setState(() {
      loginController.text = savedLogin;
      passwordController.text = savedPassword;
    });
  }

  _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('login', loginController.text);
    prefs.setString('password', passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Webview Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: loginController,
              decoration: InputDecoration(
                labelText: 'Логин',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _login(context);
                print(loginController);
              },
              child: Text('Войти' , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _login(BuildContext context) async {
    final webViewController = await this.webViewController.future;

    webViewController.evaluateJavascript(
        'document.getElementsByName("login")[0].value="${loginController.text}";');
    webViewController.evaluateJavascript(
        'document.getElementsByName("password")[0].value="${passwordController.text}";');
    webViewController.evaluateJavascript(
        'document.getElementsByClassName("btn-form")[0].click();');
    _saveCredentials();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(webViewController: webViewController),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  late final WebViewController webViewController;

  ResultScreen({required this.webViewController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Результат входа'),
      ),
      body: WebView(
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        initialUrl: 'https://mobile.paloma365.com/login.php',
      ),
    );
  }
}
