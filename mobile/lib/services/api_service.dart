import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../models/user_profile.dart';

class ApiService {
  static String get baseUrl => ApiClient.defaultBaseUrl;

  static final ApiClient client = ApiClient();

  static Future<http.Response> getCurrentUser(String accessToken) async {
    return await http.get(
      Uri.parse('$baseUrl/api/v1/users/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }

  static Future<UserProfile> fetchUserProfile() async {
    return await client.getCurrentUser();
  }
}