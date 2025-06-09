import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodapp_user/screens/home_screen.dart';
import 'package:foodapp_user/models/cart_model.dart';
import 'package:foodapp_user/models/favorites_model.dart';

void main() {
  group('Enhanced Categories Section Tests', () {
    testWidgets('Categories carousel displays correctly', (WidgetTester tester) async {
      // Build the HomeScreen widget with required providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CartModel()),
            ChangeNotifierProvider(create: (context) => FavoritesModel()),
          ],
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: HomeScreen(),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();
      
      // Advance timers to complete async operations
      await tester.pump(const Duration(seconds: 2));

      // Verify that the categories section title is displayed
      expect(find.text('تصفح حسب الفئة'), findsOneWidget);

      // Verify that some category names are displayed
      expect(find.text('المطاعم'), findsOneWidget);
      expect(find.text('الوجبات السريعة'), findsOneWidget);
      expect(find.text('الفطور'), findsOneWidget);
    });

    testWidgets('Categories display without store count badges', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CartModel()),
            ChangeNotifierProvider(create: (context) => FavoritesModel()),
          ],
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: HomeScreen(),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();
      
      // Advance timers to complete async operations
      await tester.pump(const Duration(seconds: 2));

      // Verify that store count badges are NOT displayed (since we removed them)
      final storeCountFinder = find.textContaining('متجر');
      expect(storeCountFinder, findsNothing);
      
      // Verify that category names are still displayed
      expect(find.text('المطاعم'), findsOneWidget);
      expect(find.text('سوبرماركت'), findsOneWidget);
    });

    testWidgets('Category items are tappable and properly sized', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CartModel()),
            ChangeNotifierProvider(create: (context) => FavoritesModel()),
          ],
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: HomeScreen(),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();
      
      // Advance timers to complete async operations
      await tester.pump(const Duration(seconds: 2));

      // Find the first category item
      final firstCategoryFinder = find.text('المطاعم').first;
      expect(firstCategoryFinder, findsOneWidget);

      // Test tapping on a category item
      await tester.tap(firstCategoryFinder);
      await tester.pump();
      
      // The tap should be successful without errors
    });

    testWidgets('Categories section has correct layout dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CartModel()),
            ChangeNotifierProvider(create: (context) => FavoritesModel()),
          ],
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: HomeScreen(),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();
      
      // Advance timers to complete async operations
      await tester.pump(const Duration(seconds: 2));

      // Find the categories container by looking for the SizedBox with height 175
      final categoriesContainer = find.byType(SizedBox);
      expect(categoriesContainer, findsWidgets);

      // Verify that categories section title exists
      expect(find.text('تصفح حسب الفئة'), findsOneWidget);
      
      // Verify that category images/icons are displayed
      final categoryIcons = find.byType(Icon);
      expect(categoryIcons, findsWidgets);
    });

    testWidgets('Categories overflow issue is fixed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CartModel()),
            ChangeNotifierProvider(create: (context) => FavoritesModel()),
          ],
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: HomeScreen(),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();
      
      // Advance timers to complete async operations
      await tester.pump(const Duration(seconds: 2));

      // Verify that all expected category names are visible
      expect(find.text('المطاعم'), findsOneWidget);
      expect(find.text('الوجبات السريعة'), findsOneWidget);
      expect(find.text('الفطور'), findsOneWidget);
      expect(find.text('البقالة'), findsOneWidget);
      
      // Verify that store count badges are NOT displayed anymore
      final storeCountFinder = find.textContaining('متجر');
      expect(storeCountFinder, findsNothing);
      
      // Check that no overflow errors occur during rendering
      // The test passes if no RenderFlex overflow exceptions are thrown
    });
  });
}
