import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  final String baseUrl = 'http://your-api-url.com'; // Replace with your actual API URL

  Future<String> generatePixCode(double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-pix'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': amount}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['pixCode'];
    } else {
      throw Exception('Failed to generate Pix code');
    }
  }
}