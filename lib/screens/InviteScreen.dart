import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InviteScreen extends StatefulWidget {
  final String groupId;

  InviteScreen({required this.groupId});

  @override
  _InviteScreenState createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _storage = FlutterSecureStorage();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendInvite() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'http://localhost:8000/api/convites/';
    final token = await _storage.read(key: 'token');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'grupo': widget.groupId,
          'email': _emailController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Convite enviado com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Erro desconhecido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar convite: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enviar Convite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email do Usuário',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendInvite,
                    child: Text('Enviar Convite'),
                  ),
          ],
        ),
      ),
    );
  }
}
