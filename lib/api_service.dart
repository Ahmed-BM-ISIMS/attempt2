import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vitasora/core/constants/api_constants.dart';

class ApiService {
  ApiService._();

  /// Sends [features] to the ML backend and returns the priority score.
  /// Throws an exception on network or server errors (never returns a silent 0).
  static Future<double> predict(List<double> features) async {
    final response = await http
        .post(
          Uri.parse(ApiConstants.predictEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'features': features}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final prediction = data['prediction'];
      if (prediction is List && prediction.isNotEmpty) {
        return (prediction[0] as num).toDouble();
      }
      throw const FormatException('Unexpected prediction response format');
    } else {
      throw Exception('Server error ${response.statusCode}: ${response.body}');
    }
  }
}
