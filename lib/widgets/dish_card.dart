import 'package:flutter/material.dart';
import '../models/dish_model.dart';

class DishCard extends StatelessWidget {
  final DishModel dish;
  final Function()? onTap;
  final Function()? onAddToCart;
  final bool isCompact;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
    this.onAddToCart,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          title: Text(dish.name),
          subtitle: Text('Price: ${dish.price.toStringAsFixed(2)}'),
          trailing: isCompact
              ? null
              : IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: onAddToCart,
                ),
        ),
      ),
    );
  }
}
