// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'http_service.dart';
import 'session_service.dart';

class AuthService {
  static String get _baseUrl => Config.apiBaseUrl;

  /// تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          "success": true,
          "message": responseData["message"] ?? "تم إنشاء الحساب بنجاح"
        };
      } else {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage = responseData["detail"] ?? "حدث خطأ أثناء التسجيل";
        
        // ترجمة الأخطاء الإنجليزية للعربية
        if (errorMessage.contains("Phone number already registered")) {
          errorMessage = "رقم الهاتف مسجل مسبقاً";
        } else if (errorMessage.contains("Email already registered")) {
          errorMessage = "البريد الإلكتروني مسجل مسبقاً";
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        return {
          "success": false, 
          "message": "تعذر الوصول إلى الخادم"
        };
      } else if (e.toString().contains('TimeoutException')) {
        return {
          "success": false, 
          "message": "انتهت مهلة الاتصال"
        };
      } else {
        return {
          "success": false, 
          "message": "حدث خطأ في الاتصال"
        };
      }
    }
  }

  /// تسجيل الدخول
  static Future<Map<String, dynamic>> login({
    required String identifier, // رقم الهاتف أو البريد الإلكتروني
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final token = responseData["access_token"];
        
        // جلب بيانات المستخدم باستخدام التوكن
        final userDataResult = await _fetchUserData(token);
        
        return {
          "success": true,
          "data": {
            "access_token": token,
            "token_type": responseData["token_type"],
            "user": userDataResult?["user"],
            "user_id": userDataResult?["user"]?["user_id"],
          }
        };
      } else {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage = responseData["detail"] ?? "حدث خطأ أثناء تسجيل الدخول";
        
        // ترجمة الأخطاء الإنجليزية للعربية
        if (errorMessage.contains("Invalid credentials")) {
          errorMessage = "البيانات المدخلة غير صحيحة";
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        return {
          "success": false, 
          "message": "تعذر الوصول إلى الخادم"
        };
      } else if (e.toString().contains('TimeoutException')) {
        return {
          "success": false, 
          "message": "انتهت مهلة الاتصال"
        };
      } else {
        return {
          "success": false, 
          "message": "حدث خطأ في الاتصال"
        };
      }
    }
  }

  /// جلب بيانات المستخدم باستخدام التوكن
  static Future<Map<String, dynamic>?> _fetchUserData(String token) async {
    final url = Uri.parse('$_baseUrl/auth/me');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData;
      } else {
        print('⚠️ فشل في جلب بيانات المستخدم: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

  /// طلب إعادة تعيين كلمة المرور
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String identifier, // رقم الهاتف أو البريد الإلكتروني
  }) async {
    final url = Uri.parse('$_baseUrl/auth/request-password-reset');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          "success": true,
          "message": responseData["message"] ?? "تم إرسال رابط إعادة تعيين كلمة المرور"
        };
      } else {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage = responseData["detail"] ?? "حدث خطأ أثناء طلب إعادة التعيين";
        
        // ترجمة الأخطاء الإنجليزية للعربية
        if (errorMessage.contains("User not found")) {
          errorMessage = "المستخدم غير موجود";
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        return {
          "success": false, 
          "message": "تعذر الوصول إلى الخادم"
        };
      } else if (e.toString().contains('TimeoutException')) {
        return {
          "success": false, 
          "message": "انتهت مهلة الاتصال"
        };
      } else {
        return {
          "success": false, 
          "message": "حدث خطأ في الاتصال"
        };
      }
    }
  }

  /// التحقق من صحة الخادم
  static Future<bool> checkServerHealth() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// تسجيل الخروج من الخادم وتنظيف الجلسة المحلية
  static Future<Map<String, dynamic>> logout() async {
    try {
      // محاولة إشعار الخادم بتسجيل الخروج
      await HttpService.post('/auth/logout');
      
      // تنظيف الجلسة المحلية
      await SessionService.logout();
      
      return {
        'success': true,
        'message': 'تم تسجيل الخروج بنجاح'
      };
    } catch (e) {
      // تنظيف الجلسة المحلية حتى لو فشل الاتصال بالخادم
      await SessionService.logout();
      return {
        'success': true,
        'message': 'تم تسجيل الخروج بنجاح'
      };
    }
  }

  /// الحصول على معلومات المستخدم من الخادم
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await HttpService.get('/auth/profile');
      final result = await HttpService.handleResponse(response);
      
      if (result['success']) {
        return {
          'success': true,
          'data': result['data']
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'فشل في الحصول على معلومات المستخدم'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال'
      };
    }
  }

  /// تحديث معلومات المستخدم
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;

      final response = await HttpService.put('/auth/profile', body: body);
      final result = await HttpService.handleResponse(response);
      
      if (result['success']) {
        // تحديث البيانات المحلية
        if (name != null) {
          final currentData = await SessionService.getUserData();
          if (currentData != null) {
            await SessionService.saveSession(
              token: currentData['token']!,
              userId: currentData['userId']!,
              userName: name,
              userPhone: currentData['userPhone']!,
              userEmail: email ?? currentData['userEmail'],
            );
          }
        }
        
        return {
          'success': true,
          'message': 'تم تحديث المعلومات بنجاح'
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'فشل في تحديث المعلومات'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال'
      };
    }
  }
}
