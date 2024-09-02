import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart'; // Certifique-se de que o caminho está correto
import 'package:awesome_dialog/awesome_dialog.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final url = 'http://127.0.0.1:8000/api/auth/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final storage = FlutterSecureStorage();
        await storage.write(key: 'token', value: data['token']);
        await storage.write(key: 'first_name', value: data['first_name']);
        await storage.write(key: 'email', value: data['email']);

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Sucesso',
          desc: 'Login realizado com sucesso!',
          btnOkOnPress: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          },
        ).show();
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Erro desconhecido';
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Erro',
          desc: errorMessage,
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Erro',
        desc: 'Erro de conexão. Tente novamente mais tarde.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
