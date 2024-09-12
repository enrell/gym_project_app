import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gym_project_app/models/gym.dart'; // Adicione esta linha

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService._internal() {
    baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';
  }

  String? _token;

  String? getToken() {
    print('Debug: Current token: $_token'); // Debug log
    return _token;
  }

  Future<Map<String, dynamic>> performCheckIn(String qrCode) async {
    final token = await _secureStorage.read(key: 'access_token');
    final response = await http.post(
      Uri.parse('$baseUrl/process-qr'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'qrCode': qrCode}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['message']);
      print('Check-ins restantes: ${data['remainingCheckIns']}');
      return data;
    } else {
      throw Exception('Falha no check-in: ${response.body}');
    }
  }

  Future<String> processQRCode(String qrCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-in'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({'qrCode': qrCode}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'];
    } else {
      throw Exception('Failed to process QR code: ${response.body}');
    }
  }

  Future<String> login(String email, String password) async {
    print('Debug: Attempting login with email: $email');

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    print('Debug: Login response status: ${response.statusCode}');
    print('Debug: Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      await _secureStorage.write(key: 'access_token', value: token);
      print('Debug: Token set after login: $token');
      return 'Login successful';
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> register(String name, String email, String password,
      {String role = 'MEMBER'}) async {
    print(
        'Attempting to register with: name=$name, email=$email, password=${password.isNotEmpty ? '[REDACTED]' : 'empty'}, role=$role');

    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    print('Registration response status: ${response.statusCode}');
    print('Registration response body: ${response.body}');

    if (response.statusCode == 201) {
      print('Registration successful');
      return;
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      throw Exception('Invalid request data: ${errorData['message']}');
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  void logout() {
    _token = null;
    _secureStorage.delete(key: 'access_token');
  }

  Future<int> getRemainingCheckins(String gymId) async {
    final token = await _secureStorage.read(key: 'access_token');
    final url = Uri.parse('$baseUrl/check-ins/remaining').replace(
      queryParameters: {'gymId': gymId},
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Check-ins restantes: ${data['remainingCheckIns']}');
      return data['remainingCheckIns'];
    } else {
      throw Exception('Falha ao obter check-ins restantes: ${response.body}');
    }
  }

  Future<Gym?> getGymDetails(String gymId) async {
    final token = await _secureStorage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/gyms/$gymId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data is Map<String, dynamic>) {
        return Gym.fromJson(data);
      }
    }
    // Retorna null se não houver dados ou se ocorrer um erro
    return null;
  }
}
