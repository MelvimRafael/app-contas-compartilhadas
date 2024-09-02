import 'package:contas/base_service.dart';

class Usuario {
  final int id;
  final String username;
  final String fistName;
  final String lastName;
  final String email;
  final String tipo;

  Usuario({
    required this.id,
    required this.username,
    required this.fistName,
    required this.lastName,
    required this.email,
    required this.tipo,
  });

  fromJson(dynamic data) {
    return Usuario(
      id: data['id'] as int,
      username: data['username'],
      fistName: data['fistName'],
      lastName: data['lastName'],
      email: data['email'],
      tipo: data['tipo'],
    );
  }
}
