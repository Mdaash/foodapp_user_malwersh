import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8003"; // لتشغيل المحاكي

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes)); // لحل مشكلة الترميز

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "فشل تسجيل الدخول"
        };
      }
    } catch (e) {
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'address': address,
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
        return {
          "success": false,
          "message": responseData["detail"] ?? "حدث خطأ غير متوقع"
        };
      }
    } catch (e) {
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }
}
