// lib/services/optimized_api_service.dart
import 'package:flutter/foundation.dart';
import 'api_optimization_service.dart';
import 'enhanced_api_service.dart';

class OptimizedApiService {
  static final EnhancedApiService _enhancedService = EnhancedApiService();
  static bool _isInitialized = false;

  // تهيئة الخدمات
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await EnhancedApiService.initialize();
      _isInitialized = true;
      debugPrint('✅ Optimized API Service initialized');
    }
  }

  // طلبات GET مع تحسينات شاملة
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool useCache = true,
    Duration cacheDuration = const Duration(minutes: 5),
    RequestPriority priority = RequestPriority.normal,
  }) async {
    await initialize();
    
    return _enhancedService.get(
      endpoint,
      queryParams: queryParams,
      useCache: useCache,
      cacheDuration: cacheDuration,
      priority: priority,
    );
  }

  // طلبات POST مع تحسينات
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    RequestPriority priority = RequestPriority.high,
  }) async {
    await initialize();
    
    return _enhancedService.post(
      endpoint,
      body: body,
      priority: priority,
    );
  }

  // طلبات PUT مع تحسينات
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    RequestPriority priority = RequestPriority.high,
  }) async {
    await initialize();
    
    return _enhancedService.put(
      endpoint,
      body: body,
      priority: priority,
    );
  }

  // طلبات DELETE مع تحسينات
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    RequestPriority priority = RequestPriority.high,
  }) async {
    await initialize();
    
    return _enhancedService.delete(
      endpoint,
      priority: priority,
    );
  }

  // تحميل صفحات متعددة بكفاءة
  static Future<List<T>> loadMultiplePages<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    int maxPages = 5,
    int itemsPerPage = 20,
    Map<String, dynamic>? filters,
  }) async {
    await initialize();
    
    return _enhancedService.loadMultiplePages(
      endpoint,
      fromJson,
      maxPages: maxPages,
      itemsPerPage: itemsPerPage,
      filters: filters,
    );
  }

  // بحث ذكي مع اقتراحات
  static Future<SearchResult<T>> smartSearch<T>(
    String query,
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? filters,
  }) async {
    await initialize();
    
    return _enhancedService.smartSearch(
      query,
      endpoint,
      fromJson,
      filters: filters,
    );
  }

  // تحميل مجمع للبيانات
  static Future<List<T>> batchLoad<T>(
    String batchType,
    List<String> ids,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    await initialize();
    
    return _enhancedService.batchLoadData(
      batchType,
      ids,
      fromJson,
    );
  }

  // طلبات متوازية مع حد أقصى
  static Future<List<T>> parallelRequests<T>(
    List<Future<T> Function()> requestFunctions, {
    int maxConcurrency = 5,
  }) async {
    await initialize();
    
    return _enhancedService.parallelRequests(
      requestFunctions,
      maxConcurrency: maxConcurrency,
    );
  }

  // طلبات محددة للتطبيق
  
  // جلب المطاعم مع Pagination
  static Future<Map<String, dynamic>> getRestaurants({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      if (search?.isNotEmpty == true) 'search': search,
      if (category?.isNotEmpty == true) 'category': category,
      ...?filters,
    };

    return get(
      '/api/restaurants',
      queryParams: queryParams,
      useCache: true,
      cacheDuration: const Duration(minutes: 10),
      priority: RequestPriority.normal,
    );
  }

  // جلب الأطباق مع Pagination
  static Future<Map<String, dynamic>> getDishes({
    int page = 1,
    int limit = 20,
    String? storeId,
    String? category,
    String? search,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      if (storeId?.isNotEmpty == true) 'store_id': storeId,
      if (category?.isNotEmpty == true) 'category': category,
      if (search?.isNotEmpty == true) 'search': search,
      ...?filters,
    };

    return get(
      '/api/dishes',
      queryParams: queryParams,
      useCache: true,
      cacheDuration: const Duration(minutes: 5),
      priority: RequestPriority.normal,
    );
  }

  // جلب الطلبات مع Pagination
  static Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String? userId,
    String? status,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      if (userId?.isNotEmpty == true) 'user_id': userId,
      if (status?.isNotEmpty == true) 'status': status,
      ...?filters,
    };

    return get(
      '/api/orders',
      queryParams: queryParams,
      useCache: false, // الطلبات تتغير باستمرار
      priority: RequestPriority.high,
    );
  }

  // تسجيل الدخول مع أولوية عالية
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    return post(
      '/auth/login',
      body: {
        'identifier': identifier,
        'password': password,
      },
      priority: RequestPriority.critical,
    );
  }

  // إنشاء طلب جديد
  static Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> orderData,
  }) async {
    return post(
      '/api/orders',
      body: orderData,
      priority: RequestPriority.critical,
    );
  }

  // إحصائيات الأداء
  static Map<String, dynamic> getPerformanceStats() {
    return _enhancedService.getPerformanceStats();
  }

  // تنظيف الموارد
  static void dispose() {
    _enhancedService.dispose();
  }
}

// دعم للطلبات الخاصة بالمطاعم
extension RestaurantApiExtensions on OptimizedApiService {
  // جلب تفاصيل مطعم واحد
  static Future<Map<String, dynamic>> getRestaurantDetails(String restaurantId) async {
    return OptimizedApiService.get(
      '/api/restaurants/$restaurantId',
      useCache: true,
      cacheDuration: const Duration(minutes: 15),
      priority: RequestPriority.high,
    );
  }

  // جلب فئات المطعم
  static Future<Map<String, dynamic>> getRestaurantCategories(String restaurantId) async {
    return OptimizedApiService.get(
      '/api/restaurants/$restaurantId/categories',
      useCache: true,
      cacheDuration: const Duration(hours: 1),
      priority: RequestPriority.normal,
    );
  }

  // جلب الأطباق المتاحة
  static Future<Map<String, dynamic>> getAvailableDishes(String restaurantId) async {
    return OptimizedApiService.get(
      '/api/restaurants/$restaurantId/dishes/available',
      useCache: true,
      cacheDuration: const Duration(minutes: 5),
      priority: RequestPriority.normal,
    );
  }
}

// دعم للطلبات الخاصة بالمستخدم
extension UserApiExtensions on OptimizedApiService {
  // جلب ملف المستخدم
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return OptimizedApiService.get(
      '/api/users/$userId',
      useCache: true,
      cacheDuration: const Duration(minutes: 30),
      priority: RequestPriority.high,
    );
  }

  // تحديث ملف المستخدم
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    return OptimizedApiService.put(
      '/api/users/$userId',
      body: userData,
      priority: RequestPriority.high,
    );
  }

  // جلب المفضلات
  static Future<Map<String, dynamic>> getUserFavorites(String userId) async {
    return OptimizedApiService.get(
      '/api/users/$userId/favorites',
      useCache: true,
      cacheDuration: const Duration(minutes: 10),
      priority: RequestPriority.normal,
    );
  }
}
