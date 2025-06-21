// lib/services/http_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'session_service.dart';

class HttpService {
  static String get _baseUrl => Config.apiBaseUrl;

  /// إرسال طلب GET مع التوكن
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.get(url, headers: headers);
  }

  /// إرسال طلب POST مع التوكن
  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// إرسال طلب PUT مع التوكن
  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// إرسال طلب DELETE مع التوكن
  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.delete(url, headers: headers);
  }

  /// إرسال طلب بدون توكن (للمصادقة)
  static Future<http.Response> postPublic(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};
    
    return await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// بناء headers مع التوكن
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    
    // إضافة التوكن إذا كان متاحاً
    final authHeader = await SessionService.getAuthHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
    
    return headers;
  }

  /// التحقق من حالة الاستجابة ومعالجة أخطاء التوكن
  static Future<Map<String, dynamic>> handleResponse(http.Response response) async {
    // إذا كان التوكن منتهي الصلاحية
    if (response.statusCode == 401) {
      await SessionService.logout();
      return {
        'success': false,
        'message': 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى',
        'requiresLogin': true
      };
    }

    // تحديث وقت آخر نشاط عند النجاح
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await SessionService.refreshSession();
    }

    try {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': responseData,
        'statusCode': response.statusCode
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في معالجة الاستجابة',
        'statusCode': response.statusCode
      };
    }
  }
}
