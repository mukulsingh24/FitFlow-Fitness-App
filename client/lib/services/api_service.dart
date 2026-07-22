import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> saveBMI({
    required double weight,
    required double heightCm,
  }) async {
    print('STEP 1: saveBMI called');

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('STEP ERROR: User is null');
      throw Exception('User is not logged in');
    }

    print('STEP 2: User found: ${user.email}');

    final String? token = await user.getIdToken();

    if (token == null) {
      print('STEP ERROR: Firebase token is null');
      throw Exception('Unable to get Firebase ID token');
    }

    print('STEP 3: Firebase token received');
    print('STEP 4: Sending POST to $baseUrl/health/bmi');
    print('DATA: weight=$weight, heightCm=$heightCm');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/health/bmi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'weight': weight, 'height_cm': heightCm}),
      );

      print('STEP 5: Response received');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception(
        'Failed to save BMI (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      print('HTTP POST ERROR: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> getBMIHistory() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final String? token = await user.getIdToken();

    if (token == null) {
      throw Exception('Unable to get Firebase ID token');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/health/bmi'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load BMI history (${response.statusCode}): ${response.body}',
    );
  }

  static Future<Map<String, dynamic>?> getLatestBMI() async {
    final history = await getBMIHistory();

    if (history.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(history.first);
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final String? token = await user.getIdToken();

    if (token == null) {
      throw Exception('Unable to get Firebase ID token');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('API Error ${response.statusCode}: ${response.body}');
  }
}
