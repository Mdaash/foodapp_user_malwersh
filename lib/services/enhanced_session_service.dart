// lib/services/enhanced_session_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';

class EnhancedSessionService {
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';
  static const String _loginTimeKey = 'login_time';
  static const String _isGuestKey = 'is_guest';

  // Singleton pattern
  static final EnhancedSessionService _instance = EnhancedSessionService._internal();
  factory EnhancedSessionService() => _instance;
  EnhancedSessionService._internal();
  
  static EnhancedSessionService get instance => _instance;

  /// حفظ بيانات الجلسة بعد تسجيل الدخول
  static Future<void> saveSession({
    required String token,
    required String userId,
    required String userName,
    required String userPhone,
    String? userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // التحقق من تغيير المستخدم الفعلي
    final currentUserId = prefs.getString(_userIdKey);
    final wasGuest = prefs.getBool(_isGuestKey) ?? false;
    
    // تبديل السلة فقط في الحالات التالية:
    // 1. تغيير من ضيف إلى مستخدم مسجل
    // 2. تغيير من مستخدم إلى مستخدم آخر مختلف
    // ملاحظة: لا نمسح السلة، بل نبدلها للمستخدم الصحيح
    bool shouldSwitchCart = false;
    
    if (wasGuest) {
      // إذا كان المستخدم السابق ضيف، بدل للسلة المسجلة
      shouldSwitchCart = true;
    } else if (currentUserId != null && currentUserId != userId) {
      // إذا تغير المستخدم إلى مستخدم مختلف، بدل لسلته
      shouldSwitchCart = true;
    }
    
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userPhoneKey, userPhone);
    if (userEmail != null && userEmail.isNotEmpty) {
      await prefs.setString(_userEmailKey, userEmail);
    }
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
    await prefs.setBool(_isGuestKey, false); // المستخدم مسجل الدخول
    
    // تبديل السلة فقط عند الحاجة
    if (shouldSwitchCart) {
      UserSession.notifySessionChange();
    }
  }

  /// حفظ حالة الضيف
  static Future<void> saveGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, true);
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
    
    // إزالة بيانات المستخدم المسجل إن وجدت
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userEmailKey);
  }

  /// تفعيل وضع الضيف
  static Future<void> setGuestMode() async {
    await saveGuestSession();
    
    // تفعيل callback لتبديل السلة عند الدخول كضيف
    UserSession.notifySessionChange();
  }

  /// الحصول على التوكن المحفوظ
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// الحصول على التوكن مع Bearer prefix
  static Future<String?> getAuthHeader() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      return 'Bearer $token';
    }
    return null;
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

  /// التحقق من وجود جلسة نشطة (مسجل الدخول)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool(_isGuestKey) ?? false;
    final token = prefs.getString(_tokenKey);
    return !isGuest && token != null && token.isNotEmpty;
  }

  /// التحقق من حالة الضيف
  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false;
  }

  /// التحقق من وجود أي جلسة (مسجل أو ضيف)
  static Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getString(_loginTimeKey);
    return loginTime != null;
  }

  /// الحصول على حالة المستخدم (Guest, LoggedIn, None)
  static Future<String> getUserStatus() async {
    if (await isLoggedIn()) return 'LoggedIn';
    if (await isGuest()) return 'Guest';
    return 'None';
  }

  /// الحصول على بيانات الجلسة الحالية
  static Future<Map<String, dynamic>> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuestUser = prefs.getBool(_isGuestKey) ?? false;
    
    if (isGuestUser) {
      return {
        'isLoggedIn': false,
        'isGuest': true,
        'userName': 'ضيف',
        'userEmail': null,
        'userPhone': null,
        'loginTime': prefs.getString(_loginTimeKey),
      };
    } else {
      final token = prefs.getString(_tokenKey);
      return {
        'isLoggedIn': token != null && token.isNotEmpty,
        'isGuest': false,
        'token': token,
        'userId': prefs.getString(_userIdKey),
        'userName': prefs.getString(_userNameKey),
        'userPhone': prefs.getString(_userPhoneKey),
        'userEmail': prefs.getString(_userEmailKey),
        'loginTime': prefs.getString(_loginTimeKey),
      };
    }
  }

  /// الحصول على جميع بيانات المستخدم المسجل
  static Future<Map<String, dynamic>?> getUserData() async {
    final isLoggedInUser = await isLoggedIn();
    if (!isLoggedInUser) return null;

    return {
      'token': await getToken(),
      'userId': await getUserId(),
      'userName': await getUserName(),
      'userPhone': await getUserPhone(),
      'userEmail': await getUserEmail(),
      'isGuest': false,
    };
  }

  /// تسجيل الخروج وحذف البيانات المحفوظة
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_loginTimeKey);
    await prefs.remove(_isGuestKey);
    
    // ملاحظة: لا نمسح السلة عند تسجيل الخروج
    // السلة ستبقى محفوظة لنفس المستخدم عند تسجيل الدخول مرة أخرى
    // فقط نخبر النظام بتغيير الجلسة لإعادة تحميل السلة المناسبة
    UserSession.notifySessionChange();
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

  /// التحقق من صلاحية التوكن
  static Future<bool> isTokenValid() async {
    final loginTime = await getLoginTime();
    if (loginTime == null) return false;
    
    // التوكن صالح لمدة 24 ساعة
    final expiryTime = loginTime.add(const Duration(hours: 24));
    return DateTime.now().isBefore(expiryTime);
  }

  /// تحديث بيانات المستخدم
  static Future<void> updateUserInfo({
    String? userName,
    String? userEmail,
    String? userPhone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (userName != null) await prefs.setString(_userNameKey, userName);
    if (userEmail != null) await prefs.setString(_userEmailKey, userEmail);
    if (userPhone != null) await prefs.setString(_userPhoneKey, userPhone);
  }

  /// تجديد وقت الجلسة
  static Future<void> refreshSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
  }
}
