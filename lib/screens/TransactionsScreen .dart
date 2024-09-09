import 'package:contas/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  TransactionsScreen({required this.groupId, required this.groupName});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  final _storage = FlutterSecureStorage();
  List<dynamic> _transactions = [];
  List<dynamic> _members = [];
  bool _isTransactionsLoading = true;
  bool _isMembersLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
    _loadMembers();
  }

  Future<void> _loadTransactions() async {
    final url =
        'http://localhost:8000/api/transacoes/${widget.groupId}/';

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('Token não encontrado.');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          _transactions = data;
          _isTransactionsLoading = false;
        });
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        print('Erro ao carregar transações: $errorMessage');
        setState(() => _isTransactionsLoading = false);
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
      setState(() => _isTransactionsLoading = false);
    }
  }
Future<void> _loadMembers() async {
  final url = 'http://localhost:8000/api/grupo/${widget.groupId}/membros';
  try {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Token não encontrado.');
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      setState(() {
        _members = data;
        _isMembersLoading = false;
      });
      print('Membros carregados: $_members');
    } else {
      final errorMessage = json.decode(response.body)['error'] ?? 'Erro desconhecido';
      print('Erro ao carregar membros: $errorMessage');
      setState(() => _isMembersLoading = false);
    }
  } catch (e) {
    print('Erro ao processar a resposta: $e');
    setState(() => _isMembersLoading = false);
  }
}

  Widget _buildMembersTab() {
    return _isMembersLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(member['email'] ?? 'Email não disponível'),
                ),
              );
            },
          );
  }

  Future<void> _inviteMember(String email) async {
    final url = 'http://localhost:8000/api/grupo/${widget.groupId}/convidar/';

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
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Convite enviado: ${data}');
        await _loadMembers(); // Atualize a lista de membros após enviar o convite
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        print('Erro ao enviar convite: $errorMessage');
      }
    } catch (e) {
      print('Erro ao processar o convite: $e');
    }
  }

  Widget _buildTransactionsTab() {
    return _isTransactionsLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(transaction['descricao'] ??
                            'Descrição não disponível'),
                        subtitle: Text(
                          'Valor: ${transaction['valor']} - Tipo: ${transaction['tipo']} - Data: ${transaction['data_pagamento']}',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: _showAddTransactionModal,
                  icon: Icon(Icons.add),
                  label: Text('Adicionar Transação'),
                ),
              ),
            ],
          );
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionForm(
          groupId: widget.groupId,
          onTransactionAdded: () {
            _loadTransactions(); // Atualize a lista de transações
            Navigator.of(context).pop(); // Fecha o modal
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              _showInviteDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Transações'),
            Tab(text: 'Participantes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(),
          _buildMembersTab(),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Convidar Membro'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email do membro',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Convidar'),
              onPressed: () {
                final email = emailController.text;
                if (email.isNotEmpty) {
                  _inviteMember(email);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
