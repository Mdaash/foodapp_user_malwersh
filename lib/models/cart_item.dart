// lib/models/cart_item.dart

import 'package:foodapp_user/models/dish.dart';

class CartItem {
  /// معرّف المتجر الذي انبثق منه الطلب
  final String storeId;
  final Dish dish;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, Set<String>> selectedOptions;
  final String? specialInstructions;

  CartItem({
    required this.storeId,
    required this.dish,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.selectedOptions,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'dishId': dish.id,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'selectedOptions': selectedOptions.map((k, v) => MapEntry(k, v.toList())),
        'specialInstructions': specialInstructions,
      };
}
