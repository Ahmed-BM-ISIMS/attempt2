import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<String> predict(List<double> features) async {
    final response = await http.post(
      Uri.parse("http://172.30.204.102:8000/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "features": [25.0, 1.0, 0.0, 3.0, 120.0]
      }),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Failed to get prediction");
    }
  }
}