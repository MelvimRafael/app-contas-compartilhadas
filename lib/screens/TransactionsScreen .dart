import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionsScreen extends StatefulWidget {
  final String groupId; // ID do grupo para buscar transações

  TransactionsScreen({required this.groupId});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _storage = FlutterSecureStorage();
  List<dynamic> _transactions = [];
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Carregar transações ao iniciar a tela
  }

  Future<void> _loadTransactions() async {
    final url =
        'http://127.0.0.1:8000/api/transacoes?grupo_id=${widget.groupId}'; // URL para listar transações

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token ${await _storage.read(key: 'token')}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          _transactions = data; // Atualiza a lista de transações
        });
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        print('Erro ao carregar transações: $errorMessage');
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
    }
  }

  Future<void> _addTransaction(String description, double value) async {
    final url =
        'http://127.0.0.1:8000/api/transacoes'; // URL para adicionar transações

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${await _storage.read(key: 'token')}',
        },
        body: jsonEncode({
          'descricao': description,
          'valor': value,
          'grupo': widget.groupId, // ID do grupo ao qual a transação pertence
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Transação criada: $data');
        _loadTransactions(); // Atualiza a lista de transações após criação
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['error'] ?? 'Erro desconhecido';
        print('Erro ao criar transação: $errorMessage');
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
    }
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Transação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: 'Descrição da Transação'),
              ),
              TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Valor da Transação'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final description = _descriptionController.text;
                final value = double.tryParse(_valueController.text) ?? 0.0;
                if (description.isNotEmpty && value > 0) {
                  _addTransaction(description, value);
                }
                _descriptionController.clear();
                _valueController.clear();
              },
              child: Text('Adicionar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transações do Grupo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _transactions.isEmpty
            ? Center(child: Text('Nenhuma transação encontrada.'))
            : ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(transaction['descricao'] ??
                          'Descrição não encontrada'),
                      subtitle: Text('Valor: R\$${transaction['valor']}'),
                      trailing: Text(
                        '${transaction['data']}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: Icon(Icons.add),
        tooltip: 'Adicionar Transação',
      ),
    );
  }
}
