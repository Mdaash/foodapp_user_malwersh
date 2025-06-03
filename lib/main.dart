// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';          // ← استيراد provider
import 'models/cart_model.dart';                  // ← نموذج العربة
import 'screens/welcome_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),                // ← المزود للعربة
      child: const FoodAppUser(),
    ),
  );
}

class FoodAppUser extends StatelessWidget {
  const FoodAppUser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodApp User',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WelcomeScreen(),
    );
  }
}
