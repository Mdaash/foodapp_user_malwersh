// اختبار سريع لآلية الاقتراحات المحسنة
// flutter test test_suggestions.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:foodapp_user/models/store.dart';
import 'package:foodapp_user/models/menu_item.dart';
import 'package:foodapp_user/models/cart_model.dart';
import 'package:foodapp_user/models/cart_item.dart';
import 'package:foodapp_user/models/dish.dart';

void main() {
  group('Suggestions System Tests', () {
    
    test('Store should have dynamic suggestions', () {
      // إنشاء متجر مع اقتراحات ديناميكية
      final store = Store(
        id: '1',
        name: 'مطعم الاختبار',
        image: 'test.jpg',
        logoUrl: 'logo.jpg',
        isOpen: true,
        fee: '5',
        rating: '4.5',
        reviews: '100',
        distance: '2 كم',
        time: '30 دقيقة',
        address: 'شارع الاختبار',
        combos: [],
        sandwiches: [],
        drinks: [
          MenuItem(
            id: 'drink_1',
            name: 'كوكا كولا',
            description: 'مشروب منعش',
            price: 5.0,
            image: 'drink.png',
            likesPercent: 85,
            likesCount: 50,
          ),
        ],
        extras: [
          MenuItem(
            id: 'extra_1',
            name: 'بطاطس مقلية',
            description: 'إضافة لذيذة',
            price: 7.0,
            image: 'fries.png',
            likesPercent: 90,
            likesCount: 75,
          ),
        ],
        specialties: [
          MenuItem(
            id: 'specialty_1',
            name: 'برجر مميز',
            description: 'طبق مميز',
            price: 25.0,
            image: 'burger.png',
            likesPercent: 95,
            likesCount: 120,
          ),
        ],
      );

      // التحقق من وجود الاقتراحات
      expect(store.drinks.length, 1);
      expect(store.extras.length, 1);
      expect(store.specialties.length, 1);
      
      // التحقق من جودة البيانات
      expect(store.drinks.first.name, 'كوكا كولا');
      expect(store.extras.first.price, 7.0);
      expect(store.specialties.first.likesPercent, 95);
    });

    test('Cart should filter out added suggestions', () {
      // إنشاء سلة فارغة
      final cart = CartModel();
      
      // قائمة اقتراحات وهمية
      final suggestions = [
        MenuItem(
          id: 'item_1',
          name: 'طبق 1',
          description: 'وصف',
          price: 10.0,
          image: 'item1.png',
          likesPercent: 80,
          likesCount: 40,
        ),
        MenuItem(
          id: 'item_2',
          name: 'طبق 2',
          description: 'وصف',
          price: 15.0,
          image: 'item2.png',
          likesPercent: 85,
          likesCount: 60,
        ),
      ];

      // إضافة العنصر الأول للسلة
      final dish = Dish(
        id: 'item_1',
        name: 'طبق 1',
        imageUrls: ['item1.png'],
        description: 'وصف',
        likesPercent: 80,
        likesCount: 40,
        basePrice: 10.0,
        optionGroups: [],
      );

      final cartItem = CartItem(
        storeId: '1',
        dish: dish,
        quantity: 1,
        unitPrice: 10.0,
        totalPrice: 10.0,
        selectedOptions: {},
      );

      cart.addItem(cartItem);

      // تصفية الاقتراحات (محاكاة منطق الشاشة)
      final cartDishIds = cart.items.map((item) => item.dish.id).toSet();
      final filteredSuggestions = suggestions
          .where((suggestion) => !cartDishIds.contains(suggestion.id))
          .toList();

      // التحقق من النتائج
      expect(cart.items.length, 1);
      expect(suggestions.length, 2);
      expect(filteredSuggestions.length, 1);
      expect(filteredSuggestions.first.name, 'طبق 2');
    });

    test('Suggestion item should show correct status', () {
      final cart = CartModel();
      final suggestionId = 'test_item';

      // التحقق من الحالة قبل الإضافة
      bool isInCart = cart.items.any((item) => item.dish.id == suggestionId);
      expect(isInCart, false);

      // إضافة العنصر للسلة
      final dish = Dish(
        id: suggestionId,
        name: 'عنصر الاختبار',
        imageUrls: ['test.png'],
        description: 'وصف الاختبار',
        likesPercent: 90,
        likesCount: 100,
        basePrice: 20.0,
        optionGroups: [],
      );

      final cartItem = CartItem(
        storeId: '1',
        dish: dish,
        quantity: 1,
        unitPrice: 20.0,
        totalPrice: 20.0,
        selectedOptions: {},
      );

      cart.addItem(cartItem);

      // التحقق من الحالة بعد الإضافة
      isInCart = cart.items.any((item) => item.dish.id == suggestionId);
      expect(isInCart, true);
    });
  });
}
