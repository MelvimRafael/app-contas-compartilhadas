import 'package:contas/screens/TransactionsScreen%20.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = FlutterSecureStorage();
  String _name = 'Nome não encontrado';
  String _email = 'Email não encontrado';
  String _renda = 'Renda não disponível';
  String _userId = ''; // Armazenar o ID do usuário
  List<dynamic> _groups = []; // Lista para armazenar os grupos
  List<dynamic> _users = []; // Lista de usuários disponíveis para seleção
  String _selectedUserId = ''; // ID do usuário selecionado

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadGroups(); // Carregar grupos do usuário
    _loadUsers(); // Carregar lista de usuários para seleção
  }

  Future<void> _loadUserData() async {
    final url =
        'http://localhost:8000/api/auth/user-info'; // Certifique-se de que este é o endpoint correto

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token não encontrado.');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
            'Data: $data'); // Adicione esta linha para verificar a estrutura dos dados

        setState(() {
          _name = data['first_name'] ?? 'Nome não encontrado';
          _email = data['email'] ?? 'Email não encontrado';
          _userId = data['id'] ?? ''; // Armazenar o ID do usuário
          _renda = (data['renda'] ?? 0.0).toString();
          _selectedUserId = _userId; // Defina o usuário logado como padrão
        });

        print(
            'Nome do usuário: $_name'); // Verifique se o nome do usuário está correto
        print(
            'ID do usuário: $_userId'); // Verifique se o ID do usuário está correto
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        print('Erro ao carregar dados do usuário: $errorMessage');
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
    }
  }

  Future<void> _loadGroups() async {
    final url =
        'http://localhost:8000/api/grupos/meus'; // URL para listar grupos

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

  Future<void> _loadUsers() async {
    final url =
        'http://localhost:8000/api/auth/users'; // URL para listar usuários

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
          _users = data; // Atualiza a lista de usuários
          if (_users.isNotEmpty) {
            _selectedUserId =
                _users[0]['id']; // Define o primeiro usuário como padrão
          }
        });
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        print('Erro ao carregar usuários: $errorMessage');
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
    }
  }

  Future<void> _addGroup(String groupDescription) async {
    final url =
        'http://localhost:8000/api/grupos'; // URL corrigida para adicionar grupo

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token não encontrado.');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'descricao': groupDescription, // Nome do grupo a ser criado
          'dono':
              _selectedUserId, // Envie o ID do usuário selecionado como dono
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Grupo criado: $data');
        _loadGroups(); // Atualiza a lista de grupos após criação
        // Mostra o diálogo de sucesso
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Sucesso',
          desc: 'Grupo criado com sucesso!',
          btnOkOnPress: () {},
        ).show();
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['error'] ?? 'Erro desconhecido';
        print('Erro ao criar grupo: $errorMessage');
        // Mostra o diálogo de erro
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Erro',
          desc: 'Erro ao criar grupo: $errorMessage',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
      // Mostra o diálogo de erro
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Erro',
        desc: 'Erro ao processar a resposta: $e',
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<List<dynamic>> _loadGroupMembers(String groupId) async {
    final url =
        'http://localhost:8000/api/grupos/$groupId/membros'; // URL para listar membros do grupo

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token ${await _storage.read(key: 'token')}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Erro desconhecido';
        print('Erro ao carregar membros do grupo: $errorMessage');
        return [];
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
      return [];
    }
  }

  void _showGroupMembersDialog(String groupId) async {
    final members = await _loadGroupMembers(groupId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Membros do Grupo'),
          content: members.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: members.map((member) {
                    return ListTile(
                      title: Text(member['first_name']),
                    );
                  }).toList(),
                )
              : Text('Nenhum membro encontrado.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddGroupDialog() {
    final TextEditingController _groupController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Grupo'),
          content: TextField(
            controller: _groupController,
            decoration: InputDecoration(hintText: 'Nome do Grupo'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final groupDescription = _groupController.text.trim();
                if (groupDescription.isNotEmpty) {
                  _addGroup(groupDescription);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final url =
        'http://localhost:8000/api/auth/logout'; // URL do endpoint de logout

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token não encontrado.');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        await _storage.delete(
            key: 'token'); // Remove o token de armazenamento seguro
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Exibe uma mensagem de erro
        AwesomeDialog(
          context: context,
          title: 'Erro',
          body: Center(child: Text('Erro ao fazer logout')),
          dialogType: DialogType.error,
        ).show();
      }
    } catch (e) {
      print('Erro ao processar a resposta: $e');
      // Exibe uma mensagem de erro
      AwesomeDialog(
        context: context,
        title: 'Erro',
        body: Center(child: Text('Erro ao processar a resposta')),
        dialogType: DialogType.error,
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_name',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_email',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Renda: R\$$_renda',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddGroupDialog,
              child: Text('Adicionar Grupo'),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final group = _groups[index];
                  return ListTile(
                    title: Text(group['descricao']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.group),
                          onPressed: () {
                            _showGroupMembersDialog(group['id']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.money_off),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TransactionsScreen(
                                  groupId: group['id']
                                      .toString(), // Converta o ID para String
                                  groupName: group['descricao'],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
