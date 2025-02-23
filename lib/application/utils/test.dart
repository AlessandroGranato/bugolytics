import 'package:bugolytics/application/services/auth_service.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final _authService = AuthService();

  void _performLogin() async {
    await _authService.login(
      'username1',
      'testPassword',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auth Service Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed:
                  _performLogin, // Perform login when the button is pressed
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
