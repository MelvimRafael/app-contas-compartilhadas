import 'package:contas/screens/TransactionsScreen%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'login_screen.dart'; // Certifique-se de que o caminho está correto

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = FlutterSecureStorage();
  String _name = 'Nome não encontrado';
  String _email = 'Email não encontrado';
  List<dynamic> _groups = []; // Lista para armazenar os grupos

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadGroups(); // Carregar grupos do usuário
  }

  Future<void> _loadUserData() async {
    try {
      String? firstName = await _storage.read(key: 'first_name');
      String? email = await _storage.read(key: 'email');

      setState(() {
        _name = firstName ?? 'Nome não encontrado';
        _email = email ?? 'Email não encontrado';
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _loadGroups() async {
    final url =
        'http://127.0.0.1:8000/api/grupos/meus'; // URL para listar grupos

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
          _groups = data; // Atualiza a lista de grupos
        });
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        print('Erro ao carregar grupos: $errorMessage');
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
    }
  }

  Future<void> _addGroup(String groupDescription) async {
    final url =
        'http://127.0.0.1:8000/api/grupos'; // URL corrigida para adicionar grupo

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${await _storage.read(key: 'token')}',
        },
        body: jsonEncode({
          'descricao': groupDescription, // Nome do grupo a ser criado
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Grupo criado: $data');
        _loadGroups(); // Atualiza a lista de grupos após criação
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['error'] ?? 'Erro desconhecido';
        print('Erro ao criar grupo: $errorMessage');
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
    }
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String groupDescription = '';

        return AlertDialog(
          title: Text('Adicionar Grupo'),
          content: TextField(
            onChanged: (value) {
              groupDescription = value;
            },
            decoration: InputDecoration(hintText: 'Descrição do Grupo'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (groupDescription.isNotEmpty) {
                  _addGroup(groupDescription);
                }
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

  Future<void> _logout() async {
    final url = 'http://127.0.0.1:8000/api/auth/logout'; // URL de logout

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token ${await _storage.read(key: 'token')}',
        },
      );

      if (response.statusCode == 200) {
        await _storage.delete(key: 'token');
        await _storage.delete(key: 'first_name');
        await _storage.delete(key: 'email');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        print('Erro ao fazer logout: $errorMessage');
      }
    } catch (e) {
      print('Erro ao processar o logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout, // Adiciona a função de logout
          ),
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: _showAddGroupDialog, // Chama o dialog de adicionar grupo
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome e Email abaixo da AppBar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Lista de Grupos
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Meus Grupos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final group = _groups[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(group['descricao'] ??
                          'Descrição do grupo não encontrada'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionsScreen(
                              groupId:
                                  group['id'].toString(), // Passa o ID do grupo
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Resumo Financeiro
            Card(
              child: ListTile(
                title: Text('Resumo Financeiro'),
                subtitle: Text(
                    'Saldo: R\$5000\nReceitas: R\$3000\nDespesas: R\$2000'),
              ),
            ),
            SizedBox(height: 20),

            // Gráficos
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 50,
                      title: 'Receitas',
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 30,
                      title: 'Despesas',
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: 20,
                      title: 'Saldo',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
