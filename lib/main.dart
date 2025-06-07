// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';          // ← لإعدادات شريط الحالة
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
    // إعداد شريط الحالة ليكون شفافًا
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    
    return MaterialApp(
      title: 'FoodApp User',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
