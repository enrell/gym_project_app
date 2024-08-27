import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3333'; // Use 10.0.2.2 for Android emulator to access localhost

  Future<String> processQRCode(String qrCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/process-qr'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'qrCode': qrCode}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'];
    } else {
      throw Exception('Failed to process QR code');
    }
  }

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return 'Login successful';
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<String> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return 'Registration successful';
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
}