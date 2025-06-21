// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';          // ← لإعدادات شريط الحالة
import 'package:provider/provider.dart' as provider;          // ← استيراد provider
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ← استيراد Riverpod
import 'package:flutter_localizations/flutter_localizations.dart'; // ← لدعم الاتجاه العربي
import 'models/cart_model.dart';                  // ← نموذج العربة
import 'models/favorites_model.dart';             // ← نموذج المفضلة
import 'services/address_service.dart';           // ← خدمة العناوين المحسنة
import 'services/image_cache_service.dart';
import 'services/performance_optimizer_service.dart';       // ← خدمة تحسين الأداء
import 'services/optimized_api_service.dart';              // ← خدمة API المحسنة
import 'services/user_session.dart';              // ← خدمة الجلسات للربط مع السلة
import 'screens/splash_screen.dart';              // ← شاشة البداية الجديدة

void main() {
  runApp(
    // إضافة ProviderScope للـ Riverpod
    ProviderScope(
      child: provider.MultiProvider(                               // ← استخدام MultiProvider للعديد من النماذج
        providers: [
          provider.ChangeNotifierProvider(create: (_) => CartModel()),
          provider.ChangeNotifierProvider(create: (_) => FavoritesModel()),
          provider.ChangeNotifierProvider(create: (_) => EnhancedAddressService()),
        ],
        child: const FoodAppUser(),
      ),
    ),
  );
}

class FoodAppUser extends StatefulWidget {
  const FoodAppUser({super.key});

  @override
  State<FoodAppUser> createState() => _FoodAppUserState();
}

class _FoodAppUserState extends State<FoodAppUser> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // تحميل البيانات المحفوظة عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<FavoritesModel>().loadFavorites();
      context.read<EnhancedAddressService>().initialize();
      // تحميل السلة من التخزين المحلي
      context.read<CartModel>().loadFromStorage();
      
      // تهيئة كاش الصور ومحسن الأداء
      await ImageCacheService.initializeCache();
      await PerformanceOptimizerService.initialize();
      await OptimizedApiService.initialize();
      
      // ربط مسح السلة عند تغيير الجلسة وإعادة تحميلها للمستخدم الجديد
      UserSession.setSessionChangeCallback(() async {
        final cartModel = context.read<CartModel>();
        cartModel.clearOnSessionChange();
        // إعادة تحميل السلة للمستخدم الجديد بعد تأخير قصير
        await Future.delayed(const Duration(milliseconds: 100));
        cartModel.loadFromStorage();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // التطبيق عاد للمقدمة - تحميل السلة إذا لزم الأمر
        debugPrint('التطبيق عاد للمقدمة');
        if (context.read<CartModel>().isLoaded) {
          context.read<CartModel>().loadFromStorage();
        }
        break;
      case AppLifecycleState.paused:
        // التطبيق ذهب للخلفية - حفظ السلة
        debugPrint('التطبيق ذهب للخلفية - حفظ السلة');
        context.read<CartModel>().saveToStorage();
        break;
      case AppLifecycleState.detached:
        // التطبيق يتم إغلاقه - حفظ السلة
        debugPrint('التطبيق يتم إغلاقه - حفظ السلة');
        context.read<CartModel>().saveToStorage();
        break;
      case AppLifecycleState.inactive:
        // التطبيق غير نشط مؤقتاً
        break;
      case AppLifecycleState.hidden:
        // التطبيق مخفي
        break;
    }
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
      home: const SplashScreen(), // ابدأ من شاشة البداية الذكية
    );
  }
}
