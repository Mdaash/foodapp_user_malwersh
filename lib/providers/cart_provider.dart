// lib/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_model.dart';

// مزود الحالة للسلة باستخدام Riverpod
final cartProvider = ChangeNotifierProvider<CartModel>((ref) {
  return CartModel();
});

// مزود للعدد الإجمالي للعناصر في السلة
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.fold(0, (sum, item) => sum + item.quantity);
});

// مزود للمبلغ الإجمالي للسلة
final cartTotalAmountProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalAmount;
});

// مزود لحالة فراغ السلة
final isCartEmptyProvider = Provider<bool>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.isEmpty;
});

// مزود لمتجر السلة الحالي
final cartStoreProvider = Provider<String?>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.currentStoreId;
});
