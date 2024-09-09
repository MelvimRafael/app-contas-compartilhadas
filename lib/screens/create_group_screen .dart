import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> _createGroup() async {
    final url = 'http://localhost:8000/api/grupos'; // Ajuste para o URL correto

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token não encontrado.');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'descricao': _nameController.text,
        }),
      );

      if (response.statusCode == 201) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Sucesso',
          desc: 'Grupo criado com sucesso!',
          btnOkOnPress: () {
            Navigator.pop(context); // Voltar para a tela anterior
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
      print('Erro ao processar a resposta: $e');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Erro',
        desc: 'Erro ao criar o grupo. Tente novamente mais tarde.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Grupo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome do Grupo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createGroup,
              child: Text('Criar Grupo'),
            ),
          ],
        ),
      ),
    );
  }
}
