import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodapp_user/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodAppUser());
    await tester.pumpAndSettle();
    
    // نتأكد من أن التطبيق يعمل بدون أخطاء
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
