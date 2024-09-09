import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'login_screen.dart'; // Certifique-se de que o caminho está correto

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  Future<void> _signup() async {
    final url = 'http://127.0.0.1:8000/api/auth/signup/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'password2': _confirmPasswordController.text,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Sucesso no cadastro
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
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Erro de conexão. Tente novamente mais tarde.');
    }
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: 'Erro',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirme a Senha'),
                obscureText: true,
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
                controller: _incomeController,
                decoration: InputDecoration(labelText: 'Renda'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  child: Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
