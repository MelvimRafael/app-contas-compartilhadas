import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart'; // Certifique-se de que o caminho está correto

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _storage = FlutterSecureStorage();

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Erro',
        desc: 'Senhas não coincidem',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    // Preparando os dados para envio
    final body = jsonEncode({
      'username': _usernameController.text,
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'password2': _confirmPasswordController.text,
    });

    // Depuração: imprimindo o corpo da requisição
    print("Corpo da requisição: $body");

    final response = await http.post(
      // Use '10.0.2.2' se estiver usando um emulador Android
      Uri.parse('http://127.0.0.1:8000/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    // Depuração: imprimindo o status code e a resposta
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Sucesso',
        desc: 'Cadastro realizado com sucesso!',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
      ).show();
    } else {
      final errorMessage =
          json.decode(response.body)['error'] ?? 'Erro desconhecido';
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Erro',
        desc: errorMessage,
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Primeiro Nome'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Último Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmação de Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: Text('Cadastrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Voltar para a tela de login
              },
              child: Text('Já tem uma conta? Faça login'),
            ),
          ],
        ),
      ),
    );
  }
}
