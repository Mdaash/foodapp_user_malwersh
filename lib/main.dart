// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';          // ← لإعدادات شريط الحالة
import 'package:provider/provider.dart';          // ← استيراد provider
import 'package:flutter_localizations/flutter_localizations.dart'; // ← لدعم الاتجاه العربي
import 'models/cart_model.dart';                  // ← نموذج العربة
import 'models/favorites_model.dart';             // ← نموذج المفضلة
import 'services/address_service.dart';           // ← خدمة العناوين
import 'screens/welcome_screen.dart';                // ← استيراد WelcomeScreen كبداية

void main() {
  runApp(
    MultiProvider(                               // ← استخدام MultiProvider للعديد من النماذج
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
        ChangeNotifierProvider(create: (_) => AddressService()),
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
      context.read<AddressService>().initialize();
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
      // إعداد الاتجاه العربي (RTL)
      locale: const Locale('ar', 'AE'), // العربية (الإمارات)
      supportedLocales: const [
        Locale('ar', 'AE'), // العربية
        Locale('en', 'US'), // الإنجليزية
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        // إجبار الاتجاه من اليمين إلى اليسار
        useMaterial3: true,
        fontFamily: 'Cairo', // يمكن إضافة خط عربي إذا كان متاحاً
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        // إعداد اتجاه النص الافتراضي
        textTheme: const TextTheme().apply(
          fontFamily: 'Cairo',
        ),
      ),
      // بناء التطبيق مع اتجاه RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const WelcomeScreen(), // ابدأ من شاشة السبلاش/الترحيب
    );
  }
}
