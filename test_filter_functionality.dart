// Test file to verify filter functionality
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/models/favorites_model.dart';
import 'lib/models/cart_model.dart';
import 'lib/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
      ],
      child: MaterialApp(
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
