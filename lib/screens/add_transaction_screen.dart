import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTransactionForm extends StatefulWidget {
  final String groupId;
  final VoidCallback onTransactionAdded;

  AddTransactionForm({required this.groupId, required this.onTransactionAdded});

  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();
  String _type = 'Despesas'; // Tipo padrão

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Descrição'),
          ),
          TextField(
            controller: _valueController,
            decoration: InputDecoration(labelText: 'Valor'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _dateController,
            decoration: InputDecoration(labelText: 'Data (YYYY-MM-DD)'),
            keyboardType: TextInputType.datetime,
          ),
          DropdownButton<String>(
            value: _type,
            onChanged: (String? newValue) {
              setState(() {
                _type = newValue!;
              });
            },
            items: <String>['Despesas', 'Receitas']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addTransaction,
            child: Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction() async {
    final description = _descriptionController.text;
    final value = _valueController.text;
    final date = _dateController.text;

    if (description.isEmpty || value.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final url = 'http://localhost:8000/api/transacoes/'; // URL corrigida

    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      final userId = await storage.read(key: 'userId'); // Adicione a leitura do ID do usuário

      print('Token: $token'); // Adicione logs para depuração
      print('UserId: $userId'); // Adicione logs para depuração

      if (token == null || userId == null) {
        throw Exception('Token ou ID do usuário não encontrados.');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'descricao': description,
          'valor': double.tryParse(value),
          'data_pagamento': date,
          'tipo': _type,
          'grupo': widget.groupId,
          'dono': userId, // Configura o dono como o usuário logado
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        widget.onTransactionAdded(); // Notifica que a transação foi adicionada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transação adicionada com sucesso')),
        );
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar transação: $errorMessage')),
        );
      }
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar transação')),
      );
    }
  }
}
