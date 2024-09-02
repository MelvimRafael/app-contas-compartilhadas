import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchData() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('https://localhost.com/api/contas_compartilhadas/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Processar dados
    } else {
      // Tratar erro
    }
  }
}
