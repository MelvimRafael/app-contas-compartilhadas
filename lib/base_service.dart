import 'dart:convert';

import 'package:http/http.dart' as http;

class BaseService {
  final String url = 'http://localhost:80/api/';
  final String endpont;
  final String token = 'dfaf38e25c1ecd42ed67a1eb4603fa7e51c09f63';
  const BaseService({required this.endpont});

  Future<T> get<T>() async {
    var response = await http.get(Uri.parse(url + endpont), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    });
    return jsonDecode(response.body);
  }
}
