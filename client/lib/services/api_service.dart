import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> saveBMI({
    required double weight,
    required double heightCm,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Authentication required. Please log in again.');
    }

    final String? token = await user.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Unable to authenticate your account. Please log in again.',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/health/bmi'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'weight': weight, 'height_cm': heightCm}),
          )
          .timeout(const Duration(seconds: 15));

      final dynamic decodedBody;

      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid response received from the server.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decodedBody is Map<String, dynamic>) {
          return decodedBody;
        }

        throw Exception('Unexpected response format from the server.');
      }

      String message = 'Unable to save BMI.';

      if (decodedBody is Map<String, dynamic>) {
        final detail = decodedBody['detail'];

        if (detail != null) {
          message = detail.toString();
        }
      }

      switch (response.statusCode) {
        case 401:
          throw Exception('Your session has expired. Please log in again.');

        case 403:
          throw Exception('You are not authorized to perform this action.');

        case 404:
          throw Exception(
            message == 'Unable to save BMI.'
                ? 'User account was not found.'
                : message,
          );

        case 422:
          throw Exception('Please check your height and weight values.');

        case 500:
          throw Exception('Server error. Please try again later.');

        default:
          throw Exception(message);
      }
    } on TimeoutException {
      throw Exception(
        'The server is taking too long to respond. Please try again.',
      );
    } on SocketException {
      throw Exception(
        'Unable to connect to the server. Check your internet connection.',
      );
    } on http.ClientException {
      throw Exception('Unable to communicate with the server.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Something went wrong while saving your BMI.');
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

  static Future<Map<String, dynamic>> saveCalories({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    required String goal,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final String? token = await user.getIdToken();

    if (token == null) {
      throw Exception('Unable to get Firebase ID token');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/health/calories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'age': age,
        'gender': gender,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'activity_level': activityLevel,
        'goal': goal,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to save calories (${response.statusCode}): ${response.body}',
    );
  }

  static Future<List<dynamic>> getCalorieHistory() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final String? token = await user.getIdToken();

    if (token == null) {
      throw Exception('Unable to get Firebase ID token');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/health/calories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load calorie history (${response.statusCode}): ${response.body}',
    );
  }

  static Future<Map<String, dynamic>?> getLatestCalories() async {
    final history = await getCalorieHistory();

    if (history.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(history.first);
  }

  static Future<Map<String, dynamic>> saveWorkout({
    required String split,
    required String workoutDay,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final String? token = await user.getIdToken();

    if (token == null) {
      throw Exception('Unable to get Firebase ID token');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'split': split,
          'workout_day': workoutDay,
          'exercises': exercises,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        'Failed to save workout '
        '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      throw Exception('Unable to save workout: $e');
    }
  }
}
