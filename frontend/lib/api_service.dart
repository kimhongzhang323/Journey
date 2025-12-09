import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _backendUrl = 'http://127.0.0.1:8000';

  Future<Map<String, dynamic>> chat(String message, {String language = 'english'}) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message, 'language': language}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return {'response': 'Unable to connect to server.', 'type': 'text'};
    }
  }

  Future<Map<String, dynamic>> getDigitalId() async {
    try {
      final response = await http.get(Uri.parse('$_backendUrl/user/id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {}
    return {"name": "Tan Ah Kow", "id_number": "900101-14-1234", "country": "Malaysia", "qr_data": "did:my:900101141234:verify", "valid_until": "2030-12-31"};
  }
}
