import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Unified Test Suite for Frontend', () {
    test('Test server health endpoint', () async {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/health'));
      expect(response.statusCode, 200);
      expect(response.body.contains('status'), true);
    });

    test('Test cache stats endpoint', () async {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/cache/stats'));
      expect(response.statusCode, 200);
      expect(response.body.contains('connected_clients'), true);
    });

    test('Test database stats endpoint', () async {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/db/stats'));
      expect(response.statusCode, 200);
      expect(response.body.contains('connection_pool'), true);
    });

    test('Test performance overview endpoint', () async {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/performance/overview'));
      expect(response.statusCode, 200);
      expect(response.body.contains('status'), true);
    });
  });
}
