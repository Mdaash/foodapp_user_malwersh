// lib/services/session_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';
  static const String _loginTimeKey = 'login_time';

  /// حفظ بيانات الجلسة بعد تسجيل الدخول
  static Future<void> saveSession({
    required String token,
    required String userId,
    required String userName,
    required String userPhone,
    String? userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userPhoneKey, userPhone);
    if (userEmail != null) {
      await prefs.setString(_userEmailKey, userEmail);
    }
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
  }

  /// الحصول على التوكن المحفوظ
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// الحصول على معرف المستخدم
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// الحصول على اسم المستخدم
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// الحصول على رقم هاتف المستخدم
  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  /// الحصول على بريد المستخدم
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// التحقق من وجود جلسة نشطة
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// الحصول على جميع بيانات المستخدم
  static Future<Map<String, dynamic>?> getUserData() async {
    final isLoggedIn = await SessionService.isLoggedIn();
    if (!isLoggedIn) return null;

    return {
      'token': await getToken(),
      'userId': await getUserId(),
      'userName': await getUserName(),
      'userPhone': await getUserPhone(),
      'userEmail': await getUserEmail(),
    };
  }

  /// الحصول على التوكن مع Bearer prefix للاستخدام في HTTP headers
  static Future<String?> getAuthHeader() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      return 'Bearer $token';
    }
    return null;
  }

  /// التحقق من صلاحية التوكن (بناءً على وقت تسجيل الدخول)
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    final loginTime = await getLoginTime();
    
    if (token == null || token.isEmpty || loginTime == null) {
      return false;
    }
    
    // التوكن صالح لمدة 24 ساعة (يمكن تعديل هذا حسب إعدادات الخادم)
    final expiryTime = loginTime.add(const Duration(hours: 24));
    return DateTime.now().isBefore(expiryTime);
  }

  /// تجديد الجلسة (تحديث وقت آخر نشاط)
  static Future<void> refreshSession() async {
    final isValid = await isTokenValid();
    if (isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
    }
  }

  /// تسجيل الخروج وتنظيف جميع البيانات
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // حذف جميع بيانات الجلسة
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userIdKey),
      prefs.remove(_userNameKey),
      prefs.remove(_userPhoneKey),
      prefs.remove(_userEmailKey),
      prefs.remove(_loginTimeKey),
    ]);
  }

  /// الحصول على وقت تسجيل الدخول
  static Future<DateTime?> getLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_loginTimeKey);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }
}
