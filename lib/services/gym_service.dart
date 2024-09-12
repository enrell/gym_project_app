import 'package:gym_project_app/models/gym.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GymService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  GymService() : baseUrl = dotenv.env['API_URL'] ?? 'http://192.168.0.121:3333' {
    print('GymService initialized with baseUrl: $baseUrl');
  }

  Future<Map<String, dynamic>> getGyms({
    required int page,
    int perPage = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/gyms').replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      });
      print('Requesting: $url');

      final token = await _secureStorage.read(key: 'access_token');
      print('Using token: $token');

      if (token == null) {
        throw Exception('No access token available');
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<Gym> gyms = (data['gyms'] as List).map((json) => Gym.fromJson(json)).toList();
        return {
          'gyms': gyms,
          'total_pages': data['total_pages'],
        };
      } else {
        throw Exception('Failed to load gyms: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in getGyms: $e');
      rethrow;
    }
  }

  // You can keep the getNearbyGyms method if it's still needed, or remove it if not
}
