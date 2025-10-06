import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int timeoutSeconds = 15;

  static Future<Map<String, dynamic>> fetchUserData(String userId) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load user data: ${response.statusCode}\nResponse: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Data parsing error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load users: ${response.statusCode}\nResponse: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Data parsing error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Additional methods you might need for your MockAPI
  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to create user: ${response.statusCode}\nResponse: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Data parsing error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to update user: ${response.statusCode}\nResponse: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Data parsing error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete user: ${response.statusCode}\nResponse: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper method to check if API is reachable
  static Future<bool> checkApiConnection() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}