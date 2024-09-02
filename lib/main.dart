import 'package:contas/screens/dashboard_screen.dart';
import 'package:contas/screens/login_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Certifique-se de que o caminho está correto

Future<bool> isAuthenticated() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  return token != null; // Retorna verdadeiro se o token estiver presente
}

void main() {
  runApp(DevicePreview(
    enabled: true, // Habilita o Device Preview
    builder: (context) => MyApp(), // Constrói o aplicativo
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contas Compartilhadas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return DashboardScreen(); // Usuário autenticado
        } else {
          return LoginScreen(); // Usuário não autenticado
        }
      },
    );
  }
}
