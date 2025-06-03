// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';

// استبدل الاستيراد بمسار ملف main.dart الحقيقي لديك
import 'package:foodapp_user/main.dart';

void main() {
  testWidgets('App launches and shows welcome screen', (WidgetTester tester) async {
    // نشغّل التطبيق
    await tester.pumpWidget(const FoodAppUser());

    // ننتظر حتى يتم بناء الـ frame الأول
    await tester.pumpAndSettle();

    // نتأكد من وجود نص "زاد" في شاشة الترحيب
    expect(find.text('زاد'), findsOneWidget);
  });
}
