import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  // تحديد العنوان حسب النظام
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8004"; // للمحاكي Android
    } else {
      return "http://127.0.0.1:8004"; // لـ iOS أو الأجهزة الحقيقية
    }
  }

  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    final url = Uri.parse("$baseUrl/login");
    
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
        print("خطأ من الخادم: ${responseData}"); // للتشخيص
        
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
        return {"success": false, "message": "تعذر الوصول إلى الخادم. تأكد من أن الخادم يعمل على البورت 8004"};
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
    final url = Uri.parse('$baseUrl/register');
    
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

      if (response.statusCode == 200) {
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
        return {"success": false, "message": "تعذر الوصول إلى الخادم. تأكد من أن الخادم يعمل على البورت 8004"};
      } else if (e.toString().contains('TimeoutException')) {
        return {"success": false, "message": "انتهت مهلة الاتصال. تحقق من اتصال الإنترنت"};
      } else {
        return {"success": false, "message": "خطأ في التسجيل: ${e.toString()}"};
      }
    }
  }

  // جلب معلومات المستخدم
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/user/profile');
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

  // تحديث معلومات المستخدم
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
  }) async {
    final url = Uri.parse('$baseUrl/user/profile');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "فشل في تحديث الملف الشخصي"
        };
      }
    } catch (e) {
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // جلب النقاط والكوبونات
  static Future<Map<String, dynamic>> getUserRewards(String token) async {
    final url = Uri.parse('$baseUrl/user/rewards');
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
          "message": responseData["message"] ?? "فشل في جلب المكافآت"
        };
      }
    } catch (e) {
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // إضافة عنوان جديد للمستخدم (نموذج العناوين المتعددة)
  static Future<Map<String, dynamic>> addUserAddress({
    required String token,
    required String userId,
    required String name,
    required String governorate,
    required String district,
    required String neighborhood,
    required String landmark,
    bool isDefault = false,
  }) async {
    final url = Uri.parse('$baseUrl/user/$userId/addresses');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'name': name,
          'governorate': governorate,
          'district': district,
          'neighborhood': neighborhood,
          'landmark': landmark,
          'is_default': isDefault,
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
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

  // جلب عناوين المستخدم (قائمة العناوين المتعددة)
  static Future<Map<String, dynamic>> getUserAddresses(String userId) async {
    final url = Uri.parse('$baseUrl/user/$userId/addresses');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
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

  // حذف عنوان (للعناوين المتعددة)
  static Future<Map<String, dynamic>> deleteUserAddress({
    required String token,
    required String addressId,
  }) async {
    final url = Uri.parse('$baseUrl/user/addresses/$addressId');
    try {
      final response = await http.delete(
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
        // معالجة محسنة لرسائل الخطأ
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
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // تحديث عنوان (للعناوين المتعددة)
  static Future<Map<String, dynamic>> updateUserAddress({
    required String token,
    required String addressId,
    String? name,
    String? governorate,
    String? district,
    String? neighborhood,
    String? landmark,
    bool? isDefault,
  }) async {
    final url = Uri.parse('$baseUrl/user/addresses/$addressId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (governorate != null) 'governorate': governorate,
          if (district != null) 'district': district,
          if (neighborhood != null) 'neighborhood': neighborhood,
          if (landmark != null) 'landmark': landmark,
          if (isDefault != null) 'is_default': isDefault,
        }),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {"success": true, "data": responseData};
      } else {
        // معالجة محسنة لرسائل الخطأ
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
      return {"success": false, "message": "تعذر الاتصال بالخادم"};
    }
  }

  // تحديد عنوان كافتراضي
  static Future<Map<String, dynamic>> setDefaultAddress({
    required String token,
    required String addressId,
  }) async {
    return await updateUserAddress(
      token: token,
      addressId: addressId,
      isDefault: true,
    );
  }

  // دالة لاختبار الاتصال بالخادم
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = Uri.parse("$baseUrl/");
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
      if (e.toString().contains('SocketException')) {
        return {"success": false, "message": "تعذر الوصول إلى الخادم. تأكد من تشغيل الخادم على البورت 8004"};
      } else {
        return {"success": false, "message": "فشل الاتصال: ${e.toString()}"};
      }
    }
  }
}
