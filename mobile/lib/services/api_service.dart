import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<http.Response> getCurrentUser(String accessToken) async {
    return await http.get(
      Uri.parse('$baseUrl/api/v1/users/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }
}