// test/cart_security_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodapp_user/services/enhanced_session_service.dart';

void main() {
  group('نظام أمان السلة - Cart Security System Tests', () {
    setUp(() async {
      // تنظيف الاختبارات
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      // تنظيف بعد كل اختبار
      SharedPreferences.setMockInitialValues({});
    });

    test('مفاتيح السلة يجب أن تكون منفصلة لكل مستخدم', () async {
      // اختبار مفتاح الضيف
      await EnhancedSessionService.setGuestMode();
      
      String userId1 = await EnhancedSessionService.getUserId() ?? '';
      bool isGuest1 = await EnhancedSessionService.isGuest();
      String cartKey1 = _getCartKey(userId1, isGuest1);
      expect(cartKey1, 'cart_items_guest');

      // اختبار مفتاح المستخدم المسجل
      await EnhancedSessionService.saveSession(
        token: 'token_test',
        userId: 'user_123',
        userName: 'اختبار',
        userPhone: '000111222',
      );
      
      String userId2 = await EnhancedSessionService.getUserId() ?? '';
      bool isGuest2 = await EnhancedSessionService.isGuest();
      String cartKey2 = _getCartKey(userId2, isGuest2);
      expect(cartKey2, 'cart_items_user_123');

      // اختبار المستخدم الآخر
      await EnhancedSessionService.saveSession(
        token: 'token_test_2',
        userId: 'user_456',
        userName: 'اختبار 2',
        userPhone: '333444555',
      );
      
      String userId3 = await EnhancedSessionService.getUserId() ?? '';
      bool isGuest3 = await EnhancedSessionService.isGuest();
      String cartKey3 = _getCartKey(userId3, isGuest3);
      expect(cartKey3, 'cart_items_user_456');
    });

    test('بيانات الجلسة يجب أن تكون منفصلة بين المستخدمين', () async {
      // المستخدم الأول
      await EnhancedSessionService.saveSession(
        token: 'token_user_1',
        userId: 'user_1',
        userName: 'أحمد',
        userPhone: '123456789',
      );

      String? user1Id = await EnhancedSessionService.getUserId();
      String? user1Name = await EnhancedSessionService.getUserName();
      expect(user1Id, 'user_1');
      expect(user1Name, 'أحمد');

      // تبديل للمستخدم الثاني
      await EnhancedSessionService.logout();
      await EnhancedSessionService.saveSession(
        token: 'token_user_2',
        userId: 'user_2',
        userName: 'فاطمة',
        userPhone: '987654321',
      );

      String? user2Id = await EnhancedSessionService.getUserId();
      String? user2Name = await EnhancedSessionService.getUserName();
      expect(user2Id, 'user_2');
      expect(user2Name, 'فاطمة');

      // العودة للمستخدم الأول
      await EnhancedSessionService.logout();
      await EnhancedSessionService.saveSession(
        token: 'token_user_1_new',
        userId: 'user_1',
        userName: 'أحمد',
        userPhone: '123456789',
      );

      user1Id = await EnhancedSessionService.getUserId();
      user1Name = await EnhancedSessionService.getUserName();
      expect(user1Id, 'user_1');
      expect(user1Name, 'أحمد');
    });

    test('وضع الضيف يجب أن يكون منفصل عن المستخدم المسجل', () async {
      // وضع الضيف
      await EnhancedSessionService.setGuestMode();
      
      bool isGuestMode = await EnhancedSessionService.isGuest();
      bool isLoggedIn = await EnhancedSessionService.isLoggedIn();
      expect(isGuestMode, true);
      expect(isLoggedIn, false);

      // تسجيل دخول مستخدم مسجل
      await EnhancedSessionService.saveSession(
        token: 'token_registered',
        userId: 'user_registered',
        userName: 'مستخدم مسجل',
        userPhone: '111222333',
      );

      isGuestMode = await EnhancedSessionService.isGuest();
      isLoggedIn = await EnhancedSessionService.isLoggedIn();
      expect(isGuestMode, false);
      expect(isLoggedIn, true);

      // العودة لوضع الضيف
      await EnhancedSessionService.logout();
      await EnhancedSessionService.setGuestMode();
      
      isGuestMode = await EnhancedSessionService.isGuest();
      isLoggedIn = await EnhancedSessionService.isLoggedIn();
      expect(isGuestMode, true);
      expect(isLoggedIn, false);
    });

    test('حالة المستخدم يجب أن تكون صحيحة', () async {
      // لا توجد جلسة
      String status1 = await EnhancedSessionService.getUserStatus();
      expect(status1, 'None');

      // وضع الضيف
      await EnhancedSessionService.setGuestMode();
      String status2 = await EnhancedSessionService.getUserStatus();
      expect(status2, 'Guest');

      // مستخدم مسجل
      await EnhancedSessionService.saveSession(
        token: 'token_test',
        userId: 'user_test',
        userName: 'مستخدم تجريبي',
        userPhone: '555666777',
      );
      String status3 = await EnhancedSessionService.getUserStatus();
      expect(status3, 'LoggedIn');

      // تسجيل الخروج
      await EnhancedSessionService.logout();
      String status4 = await EnhancedSessionService.getUserStatus();
      expect(status4, 'None');
    });

    test('محاكاة تخزين منفصل لكل مستخدم', () async {
      final prefs = await SharedPreferences.getInstance();

      // مستخدم أ - حفظ سلة
      await EnhancedSessionService.saveSession(
        token: 'token_a',
        userId: 'user_a',
        userName: 'مستخدم أ',
        userPhone: '111',
      );
      await prefs.setString('cart_items_user_a', '["item_a1", "item_a2"]');

      // مستخدم ب - حفظ سلة
      await EnhancedSessionService.saveSession(
        token: 'token_b',
        userId: 'user_b',
        userName: 'مستخدم ب',
        userPhone: '222',
      );
      await prefs.setString('cart_items_user_b', '["item_b1"]');

      // ضيف - حفظ سلة
      await EnhancedSessionService.setGuestMode();
      await prefs.setString('cart_items_guest', '["guest_item"]');

      // التحقق من انفصال البيانات
      expect(prefs.getString('cart_items_user_a'), '["item_a1", "item_a2"]');
      expect(prefs.getString('cart_items_user_b'), '["item_b1"]');
      expect(prefs.getString('cart_items_guest'), '["guest_item"]');

      // محاكاة تبديل المستخدمين والتحقق من السلل
      await EnhancedSessionService.saveSession(
        token: 'token_a_new',
        userId: 'user_a',
        userName: 'مستخدم أ',
        userPhone: '111',
      );
      String? cartA = prefs.getString('cart_items_user_a');
      expect(cartA, '["item_a1", "item_a2"]');

      await EnhancedSessionService.saveSession(
        token: 'token_b_new',
        userId: 'user_b',
        userName: 'مستخدم ب',
        userPhone: '222',
      );
      String? cartB = prefs.getString('cart_items_user_b');
      expect(cartB, '["item_b1"]');

      await EnhancedSessionService.setGuestMode();
      String? cartGuest = prefs.getString('cart_items_guest');
      expect(cartGuest, '["guest_item"]');
    });
  });
}

// وظيفة مساعدة لتوليد مفتاح السلة
String _getCartKey(String? userId, bool isGuest) {
  if (isGuest) {
    return 'cart_items_guest';
  } else if (userId != null && userId.isNotEmpty) {
    return 'cart_items_$userId';
  } else {
    return 'cart_items_anonymous';
  }
}
