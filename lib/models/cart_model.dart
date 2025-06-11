// lib/models/cart_model.dart

import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'cart_item.dart';

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// عناصر السلة
  List<CartItem> get items => List.unmodifiable(_items);

  /// المجموع الكلي
  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// عدد العناصر في السلة
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// المعرّف الحالي للمتجر (null إذا كانت السلة فارغة)
  String? get currentStoreId =>
      _items.isEmpty ? null : _items.first.storeId;

  /// إضافة عنصر مع التحقق من المطعم
  void addItem(CartItem newItem) {
    print('Debug CartModel: محاولة إضافة عنصر ${newItem.dish.name}');
    print('Debug CartModel: storeId الحالي: $currentStoreId');
    print('Debug CartModel: storeId الجديد: ${newItem.storeId}');
    
    // إذا السلة ليست فارغة ومطعم الطلب الجديد مختلف
    if (currentStoreId != null && currentStoreId != newItem.storeId) {
      print('Debug CartModel: متجر مختلف - لن يتم إضافة العنصر');
      // لا نفعل شيء هنا، بل نوفّر التحقق في واجهة المستخدم
      return;
    }

    final existing = _items.firstWhereOrNull((item) =>
        item.dish.id == newItem.dish.id &&
        const DeepCollectionEquality()
            .equals(item.selectedOptions, newItem.selectedOptions));

    if (existing != null) {
      print('Debug CartModel: العنصر موجود بالفعل - تحديث الكمية');
      final idx = _items.indexOf(existing);
      final updatedQuantity = existing.quantity + newItem.quantity;
      final unitPrice = existing.unitPrice;
      _items[idx] = CartItem(
        storeId: existing.storeId,
        dish: existing.dish,
        quantity: updatedQuantity,
        unitPrice: unitPrice,
        totalPrice: unitPrice * updatedQuantity,
        selectedOptions: existing.selectedOptions,
        specialInstructions: existing.specialInstructions,
      );
    } else {
      print('Debug CartModel: إضافة عنصر جديد');
      _items.add(newItem);
    }

    print('Debug CartModel: عدد العناصر النهائي: ${_items.length}');
    print('Debug CartModel: المجموع النهائي: $totalAmount');
    print('Debug CartModel: استدعاء notifyListeners()');
    notifyListeners();
  }

  void updateItemQuantity(CartItem item, int newQuantity) {
    final idx = _items.indexOf(item);
    if (idx == -1) return;
    if (newQuantity <= 0) {
      _items.removeAt(idx);
    } else {
      final existing = _items[idx];
      _items[idx] = CartItem(
        storeId: existing.storeId,
        dish: existing.dish,
        quantity: newQuantity,
        unitPrice: existing.unitPrice, // يبقى ثابت
        totalPrice: existing.unitPrice * newQuantity, // فقط هذا يتغير
        selectedOptions: existing.selectedOptions,
        specialInstructions: existing.specialInstructions,
      );
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
