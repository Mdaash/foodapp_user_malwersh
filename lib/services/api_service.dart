import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_optimization_service.dart';
import 'advanced_cache_service.dart';
import 'enhanced_api_service.dart';

class ApiService with ApiOptimizationMixin {
  // خدمات التحسين
  static final AdvancedCacheService _cache = AdvancedCacheService();
  static bool _isInitialized = false;

  // تهيئة الخدمات
  static Future<void> init() async {
    if (!_isInitialized) {
      await _cache.init();
      await EnhancedApiService.initialize();
      _isInitialized = true;
      debugPrint('✅ API Service with optimizations initialized');
    }
  }

  // تحديد العنوان حسب النظام - للاتصال بخادم الإنتاج الفعلي
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8080"; // للويب - خادم الإنتاج
    } else {
      // للأجهزة المحمولة والمحاكي
      return "http://10.0.2.2:8080"; // خادم الإنتاج عبر المحاكي
    }
  }

  // للتبديل بين خادم الاختبار وخادم الإنتاج أثناء التطوير
  static String get testServerUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8004"; // للويب - خادم الاختبار
    } else {
      return "http://10.0.2.2:8004"; // خادم الاختبار عبر المحاكي
    }
  }

  // متغير للتحكم في استخدام خادم الاختبار أو الإنتاج
  static bool useTestServer = false; // تغيير إلى true لاستخدام خادم الاختبار

  // الحصول على URL الصحيح حسب الإعداد
  static String get currentBaseUrl {
    return useTestServer ? testServerUrl : baseUrl;
  }

  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    final url = Uri.parse("$currentBaseUrl/auth/login");
    
    print("محاولة الاتصال بـ: $url"); // للتشخيص
    print("البيانات المرسلة - المعرف: '$identifier', كلمة المرور: '$password'"); // للتشخيص

    try {
      final requestBody = jsonEncode({"identifier": identifier, "password": password});
      print("محتوى الطلب: $requestBody"); // للتشخيص

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      ).timeout(const Duration(seconds: 10)); // مهلة زمنية

      print("رمز الاستجابة: ${response.statusCode}"); // للتشخيص
      print("محتوى الاستجابة: ${response.body}"); // للتشخيص

      final responseData = jsonDecode(utf8.decode(response.bodyBytes)); // لحل مشكلة الترميز
      print("البيانات المفسرة: $responseData"); // للتشخيص

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
        print("خطأ من الخادم: $responseData"); // للتشخيص
        
        // معالجة محسنة لرسائل الخطأ
        String errorMessage = "فشل تسجيل الدخول";
        
        if (responseData.containsKey("message")) {
          errorMessage = responseData["message"];
        } else if (responseData.containsKey("detail")) {
          errorMessage = responseData["detail"];
        }
        
        // رسائل خاصة لأخطاء تسجيل الدخول
        if (response.statusCode == 401) {
          errorMessage = "المعلومات المدخلة خاطئة، حاول مرة أخرى";
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      print("خطأ في الاتصال: $e"); // للتشخيص
      if (e.toString().contains('SocketException')) {
        return {"success": false, "message": "تعذر الوصول إلى الخادم. تأكد من أن الخادم يعمل على البورت 8080"};
      } else if (e.toString().contains('TimeoutException')) {
        return {"success": false, "message": "انتهت مهلة الاتصال. تحقق من اتصال الإنترنت"};
      } else {
        return {"success": false, "message": "خطأ في الاتصال: ${e.toString()}"};
      }
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final url = Uri.parse('$currentBaseUrl/auth/register');
    
    print("محاولة التسجيل في: $url"); // للتشخيص
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email.isEmpty ? null : email,
          'password': password,
          'phone': phone,
        }),
      ).timeout(const Duration(seconds: 10)); // مهلة زمنية

      print("رمز استجابة التسجيل: ${response.statusCode}"); // للتشخيص
      print("محتوى استجابة التسجيل: ${response.body}"); // للتشخيص

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) { // Backend returns 201 for registration
        return {"success": true, "data": responseData};
      } else {
        // معالجة محسنة لرسائل الخطأ من الخادم
        String errorMessage = "حدث خطأ غير متوقع";
        
        if (responseData.containsKey("message")) {
          errorMessage = responseData["message"];
        } else if (responseData.containsKey("detail")) {
          errorMessage = responseData["detail"];
        }
        
        // رسائل خاصة للأخطاء الشائعة
        if (response.statusCode == 400) {
          if (errorMessage.contains("البريد الإلكتروني مسجل مسبقاً") || 
              errorMessage.contains("email") && errorMessage.contains("already")) {
            errorMessage = "البريد الإلكتروني مستخدم مسبقاً";
          } else if (errorMessage.contains("رقم الهاتف مسجل مسبقاً") || 
                     errorMessage.contains("phone") && errorMessage.contains("already")) {
            errorMessage = "رقم الهاتف مستخدم مسبقاً";
          } else {
            errorMessage = "بيانات غير صحيحة، حاول مرة أخرى";
          }
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      print("خطأ في التسجيل: $e"); // للتشخيص
      if (e.toString().contains('SocketException')) {
        return {"success": false, "message": "تعذر الوصول إلى الخادم. تأكد من أن الخادم يعمل على البورت 8080"};
      } else if (e.toString().contains('TimeoutException')) {
        return {"success": false, "message": "انتهت مهلة الاتصال. تحقق من اتصال الإنترنت"};
      } else {
        return {"success": false, "message": "خطأ في التسجيل: ${e.toString()}"};
      }
    }
  }

  // جلب معلومات المستخدم
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final url = Uri.parse('$currentBaseUrl/auth/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "فشل في جلب الملف الشخصي"
        };
      }
    } catch (e) {
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // تحديث معلومات المستخدم - TODO: Implement in backend
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
  }) async {
    // TODO: Add user profile update endpoint to backend
    return {"success": false, "message": "تحديث الملف الشخصي غير متاح حالياً"};
  }

  // جلب النقاط والكوبونات - TODO: Implement in backend  
  static Future<Map<String, dynamic>> getUserRewards(String token) async {
    // TODO: Add user rewards endpoint to backend
    return {"success": false, "message": "نظام المكافآت غير متاح حالياً"};
  }

  // إضافة عنوان جديد للمستخدم (متوافق مع خادم الإنتاج)
  static Future<Map<String, dynamic>> addUserAddress({
    required String token,
    required String name,
    required String province, // Changed from governorate to province
    required String district,
    required String neighborhood,
    required String landmark,
    bool isDefault = false,
  }) async {
    final url = Uri.parse('$currentBaseUrl/addresses'); // Fixed URL
    
    print("إضافة عنوان جديد");
    
    try {
      final requestBody = jsonEncode({
        'name': name,
        'province': province, // Fixed field name
        'district': district,
        'neighborhood': neighborhood,
        'landmark': landmark,
        'is_default': isDefault,
      });
      
      print("بيانات العنوان: $requestBody");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print("رمز استجابة إضافة العنوان: ${response.statusCode}");
      print("محتوى الاستجابة: ${response.body}");

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) { // Backend returns 201 for creation
        return {"success": true, "data": responseData};
      } else {
        // معالجة محسنة لرسائل الخطأ
        String errorMessage = "فشل في إضافة العنوان";
        
        if (responseData.containsKey("message")) {
          errorMessage = responseData["message"];
        } else if (responseData.containsKey("detail")) {
          errorMessage = responseData["detail"];
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      print("خطأ في إضافة العنوان: $e");
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // تحديث عنوان موجود (متوافق مع خادم الإنتاج)
  static Future<Map<String, dynamic>> updateUserAddress({
    required String token,
    required String addressId,
    required String name,
    required String province, // Changed from governorate to province
    required String district,
    required String neighborhood,
    required String landmark,
    bool isDefault = false,
  }) async {
    final url = Uri.parse('$currentBaseUrl/addresses/$addressId'); // Fixed URL
    
    print("تحديث العنوان: $addressId");
    
    try {
      final requestBody = jsonEncode({
        'name': name,
        'province': province, // Fixed field name
        'district': district,
        'neighborhood': neighborhood,
        'landmark': landmark,
        'is_default': isDefault,
      });
      
      print("بيانات التحديث: $requestBody");

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print("رمز استجابة تحديث العنوان: ${response.statusCode}");
      print("محتوى الاستجابة: ${response.body}");

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
        String errorMessage = "فشل في تحديث العنوان";
        
        if (responseData.containsKey("message")) {
          errorMessage = responseData["message"];
        } else if (responseData.containsKey("detail")) {
          errorMessage = responseData["detail"];
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      print("خطأ في تحديث العنوان: $e");
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // حذف عنوان (متوافق مع خادم الإنتاج)
  static Future<Map<String, dynamic>> deleteUserAddress({
    required String token,
    required String addressId,
  }) async {
    final url = Uri.parse('$currentBaseUrl/addresses/$addressId'); // Fixed URL
    
    print("حذف العنوان: $addressId");
    
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("رمز استجابة حذف العنوان: ${response.statusCode}");
      print("محتوى الاستجابة: ${response.body}");

      if (response.statusCode == 204) { // Backend returns 204 for successful deletion
        return {"success": true, "data": {"message": "تم حذف العنوان بنجاح"}};
      } else {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage = "فشل في حذف العنوان";
        
        if (responseData.containsKey("message")) {
          errorMessage = responseData["message"];
        } else if (responseData.containsKey("detail")) {
          errorMessage = responseData["detail"];
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      print("خطأ في حذف العنوان: $e");
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // تحديد عنوان كافتراضي (متوافق مع خادم الإنتاج)
  static Future<Map<String, dynamic>> setDefaultAddress({
    required String token,
    required String addressId,
  }) async {
    final url = Uri.parse('$currentBaseUrl/addresses/set-default'); // Fixed endpoint
    
    print("تحديد العنوان الافتراضي: $addressId");
    
    try {
      final requestBody = jsonEncode({
        'address_id': addressId, // Backend expects address_id
      });
      
      print("بيانات تحديد الافتراضي: $requestBody");

      final response = await http.post( // Backend uses POST for set-default
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print("رمز استجابة تحديد الافتراضي: ${response.statusCode}");
      print("محتوى الاستجابة: ${response.body}");

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
        String errorMessage = "فشل في تحديد العنوان الافتراضي";
        
        if (responseData.containsKey("message")) {
          errorMessage = responseData["message"];
        } else if (responseData.containsKey("detail")) {
          errorMessage = responseData["detail"];
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      print("خطأ في تحديد العنوان الافتراضي: $e");
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // جلب عناوين المستخدم (متوافق مع خادم الإنتاج)
  static Future<Map<String, dynamic>> getUserAddresses(String token) async {
    final url = Uri.parse('$currentBaseUrl/addresses'); // Fixed endpoint
    
    print("جلب عناوين المستخدم من: $url");
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Added authorization header
          'Content-Type': 'application/json',
        },
      );

      print("رمز استجابة جلب العناوين: ${response.statusCode}");
      print("محتوى الاستجابة: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return {"success": true, "data": responseData};
      } else {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        // معالجة محسنة لرسائل الخطأ
        String errorMessage = "فشل في جلب العناوين";
        
        if (responseData.containsKey("message")) {
          errorMessage = responseData["message"];
        } else if (responseData.containsKey("detail")) {
          errorMessage = responseData["detail"];
        }
        
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      print("خطأ في جلب العناوين: $e");
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // Added fetch method
  static Future<Map<String, dynamic>> fetch(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = Uri.parse('$currentBaseUrl$endpoint').replace(queryParameters: queryParams);
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during fetch: $e');
    }
  }

  // Added get method
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = Uri.parse('$currentBaseUrl$endpoint').replace(queryParameters: queryParams);
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during GET request: $e');
    }
  }

  // دالة لاختبار الاتصال بالخادم
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = Uri.parse("$currentBaseUrl/");
      print("اختبار الاتصال بـ: $url");
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      
      print("رمز استجابة الاختبار: ${response.statusCode}");
      
      if (response.statusCode == 200 || response.statusCode == 404) {
        return {"success": true, "message": "الخادم متصل ✅"};
      } else {
        return {"success": false, "message": "الخادم غير متاح (رمز: ${response.statusCode})"};
      }
    } catch (e) {
      print("خطأ في اختبار الاتصال: $e");
      return {"success": false, "message": "تعذر الوصول إلى الخادم: ${e.toString()}"};
    }
  }
}
