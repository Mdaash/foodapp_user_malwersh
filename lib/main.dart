// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';          // ← لإعدادات شريط الحالة
import 'package:provider/provider.dart';          // ← استيراد provider
import 'models/cart_model.dart';                  // ← نموذج العربة
import 'models/favorites_model.dart';             // ← نموذج المفضلة
import 'screens/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(                               // ← استخدام MultiProvider للعديد من النماذج
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
      ],
      child: const FoodAppUser(),
    ),
  );
}

class FoodAppUser extends StatefulWidget {
  const FoodAppUser({super.key});

  @override
  State<FoodAppUser> createState() => _FoodAppUserState();
}

class _FoodAppUserState extends State<FoodAppUser> {
  @override
  void initState() {
    super.initState();
    // تحميل المفضلة المحفوظة عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesModel>().loadFavorites();
    });
  }

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
