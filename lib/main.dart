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
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                _saveCredentials();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewScreen(),
                  ),
                );
              },
              child: Text('Войти', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('login', loginController.text);
    prefs.setString('password', passwordController.text);
  }
}

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  final Completer<WebViewController> _autoFillController = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView'),
      ),
      body: WebView(
        initialUrl: 'https://mobile.paloma365.com/login.php',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
          _autoFillController.complete(webViewController);
        },
        onPageFinished: (String url) {
          _autoFillCredentials(context);
        },
      ),
    );
  }

  _autoFillCredentials(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedLogin = prefs.getString('login') ?? '';
    String savedPassword = prefs.getString('password') ?? '';

    String autoFillScript = '''
      document.getElementsByName("login")[0].value="$savedLogin";
      document.getElementsByName("password")[0].value="$savedPassword";
      document.getElementsByClassName("btn-form")[0].click();
    ''';

    final WebViewController controller = await _autoFillController.future;
    controller.evaluateJavascript(autoFillScript);
  }
}
