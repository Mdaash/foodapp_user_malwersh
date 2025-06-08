import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../models/dish.dart';
import '../models/product.dart';
import '../models/offer.dart';
import '../models/search_result.dart';

class SearchService {
  static const String baseUrl = 'http://10.0.2.2:8003/api'; // نفس baseUrl من ApiService
  static const Duration _debounceTime = Duration(milliseconds: 500);
  
  Timer? _debounceTimer;
  final Map<String, List<Store>> _searchCache = {};
  final Map<String, List<SearchResult>> _mixedSearchCache = {};

  // البحث مع debouncing لتحسين الأداء
  Future<List<Store>> searchStores(String query, {
    String? category,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    if (query.trim().isEmpty) return [];

    // التحقق من الكاش أولاً
    final cacheKey = _generateCacheKey(query, category, latitude, longitude);
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    try {
      final response = await _performSearchRequest(
        query: query,
        category: category,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Store> stores = (data['stores'] as List)
            .map((storeJson) => Store.fromJson(storeJson))
            .toList();

        // حفظ في الكاش
        _searchCache[cacheKey] = stores;
        
        // تنظيف الكاش إذا أصبح كبيراً
        if (_searchCache.length > 50) {
          _searchCache.clear();
        }

        return stores;
      } else {
        throw Exception('فشل في البحث: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('خطأ في البحث: $e');
      return [];
    }
  }

  // البحث مع debouncing
  Future<List<Store>> searchWithDebounce(String query, {
    String? category,
    double? latitude,
    double? longitude,
    int? radius,
    required Function(List<Store>) onResults,
  }) async {
    // إلغاء البحث السابق
    _debounceTimer?.cancel();
    
    final completer = Completer<List<Store>>();
    
    _debounceTimer = Timer(_debounceTime, () async {
      try {
        final results = await searchStores(
          query,
          category: category,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
        onResults(results);
        completer.complete(results);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  // إجراء طلب البحث للباك إند
  Future<http.Response> _performSearchRequest({
    required String query,
    String? category,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    final Map<String, dynamic> params = {
      'q': query,
      'lang': 'ar', // اللغة العربية
    };

    if (category != null) params['category'] = category;
    if (latitude != null) params['lat'] = latitude.toString();
    if (longitude != null) params['lng'] = longitude.toString();
    if (radius != null) params['radius'] = radius.toString();

    final uri = Uri.parse('$baseUrl/search/stores').replace(
      queryParameters: params,
    );

    return await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
      },
    ).timeout(const Duration(seconds: 10));
  }

  // توليد مفتاح الكاش
  String _generateCacheKey(String query, String? category, double? lat, double? lng) {
    return '$query|$category|$lat|$lng'.toLowerCase();
  }

  // البحث الشائع من الباك إند
  Future<List<String>> getPopularSearches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/popular'),
        headers: {
          'Accept-Language': 'ar',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['popular_searches']);
      }
    } catch (e) {
      debugPrint('خطأ في جلب البحث الشائع: $e');
    }

    // قائمة افتراضية في حالة الفشل
    return [
      'برجر',
      'بيتزا',
      'دجاج مقلي',
      'سوشي',
      'شاورما',
      'مأكولات آسيوية',
      'معجنات',
      'مشروبات',
      'حلويات',
      'مأكولات بحرية',
    ];
  }

  // اقتراحات البحث التلقائي
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/suggestions?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Accept-Language': 'ar',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['suggestions']);
      }
    } catch (e) {
      debugPrint('خطأ في جلب اقتراحات البحث: $e');
    }

    return [];
  }

  // تنظيف الكاش
  void clearCache() {
    _searchCache.clear();
    _mixedSearchCache.clear();
  }

  // تسجيل إحصائيات البحث
  Future<void> logSearchEvent(String query, int resultsCount) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/search/analytics'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'query': query,
          'results_count': resultsCount,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      // تجاهل الأخطاء في الإحصائيات
      debugPrint('خطأ في تسجيل إحصائيات البحث: $e');
    }
  }

  // إلغاء العمليات المعلقة
  void dispose() {
    _debounceTimer?.cancel();
  }

  // البحث العام والديناميكي في جميع أنواع المحتوى
  Future<List<SearchResult>> searchUniversal(String query, {
    List<Store>? localStores,
    List<SearchResultType>? searchTypes, // تحديد الأنواع المطلوب البحث فيها
    String? category,
    double? latitude,
    double? longitude,
    int? limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    // إذا لم تحدد أنواع البحث، ابحث في كل شيء
    searchTypes ??= SearchResultType.values;

    final results = <SearchResult>[];
    
    // البحث المحلي أولاً للسرعة
    if (localStores != null) {
      // البحث في المتاجر
      if (searchTypes.contains(SearchResultType.store)) {
        final storeResults = _searchLocalStores(query, localStores);
        results.addAll(storeResults.map((store) => SearchResult.fromStore(store)));
      }
      
      // البحث في الأطباق
      if (searchTypes.contains(SearchResultType.dish)) {
        final dishResults = _searchLocalDishes(query, localStores);
        results.addAll(dishResults);
      }
      
      // البحث في المنتجات (للسوبرماركت)
      if (searchTypes.contains(SearchResultType.product)) {
        final productResults = _searchLocalProducts(query, localStores);
        results.addAll(productResults);
      }
      
      // البحث في العروض
      if (searchTypes.contains(SearchResultType.offer)) {
        final offerResults = _searchLocalOffers(query, localStores);
        results.addAll(offerResults);
      }
      
      // البحث في الفئات
      if (searchTypes.contains(SearchResultType.category)) {
        final categoryResults = _searchCategories(query, localStores);
        results.addAll(categoryResults);
      }
    }

    try {
      // البحث من الباك إند للنتائج الإضافية
      final backendResults = await _searchBackendUniversal(
        query, 
        searchTypes, 
        category, 
        latitude, 
        longitude
      );
      
      // دمج النتائج وإزالة المكررات
      final seenIds = results.map((r) => r.id).toSet();
      for (final result in backendResults) {
        if (!seenIds.contains(result.id)) {
          results.add(result);
          seenIds.add(result.id);
        }
      }
    } catch (e) {
      debugPrint('خطأ في البحث العام من الباك إند: $e');
    }

    // ترتيب النتائج حسب الصلة
    _sortSearchResults(results, query);
    
    // تحديد النتائج حسب الحد المطلوب
    final finalResults = results.take(limit ?? 20).toList();
    
    return finalResults;
  }

  // البحث المحلي في المنتجات
  List<SearchResult> _searchLocalProducts(String query, List<Store> stores) {
    final normalizedQuery = _normalizeSearchText(query);
    final results = <SearchResult>[];
    
    for (final store in stores) {
      // البحث في منتجات السوبرماركت
      if (_isSupermarket(store)) {
        final mockProducts = _getMockProductsForStore(store.id);
        
        for (final product in mockProducts) {
          final productName = _normalizeSearchText(product.name);
          final productCategory = _normalizeSearchText(product.category);
          final productBrand = _normalizeSearchText(product.brand);
          
          if (productName.contains(normalizedQuery) || 
              productCategory.contains(normalizedQuery) ||
              productBrand.contains(normalizedQuery) ||
              _isPartialMatch(productName, normalizedQuery)) {
            results.add(SearchResult.fromProduct(product, store.name));
          }
        }
      }
    }
    
    return results;
  }

  // البحث المحلي في العروض
  List<SearchResult> _searchLocalOffers(String query, List<Store> stores) {
    final normalizedQuery = _normalizeSearchText(query);
    final results = <SearchResult>[];
    
    for (final store in stores) {
      final mockOffers = _getMockOffersForStore(store.id, store.name);
      
      for (final offer in mockOffers) {
        final offerTitle = _normalizeSearchText(offer.title);
        final offerDescription = _normalizeSearchText(offer.description);
        
        if (offerTitle.contains(normalizedQuery) || 
            offerDescription.contains(normalizedQuery) ||
            _isPartialMatch(offerTitle, normalizedQuery)) {
          results.add(SearchResult.fromOffer(offer));
        }
      }
    }
    
    return results;
  }

  // البحث في الفئات
  List<SearchResult> _searchCategories(String query, List<Store> stores) {
    final normalizedQuery = _normalizeSearchText(query);
    final categoryMap = <String, int>{};
    
    // تجميع المتاجر حسب الفئات
    for (final store in stores) {
      final category = store.category ?? 'أخرى';
      categoryMap[category] = (categoryMap[category] ?? 0) + 1;
    }
    
    final results = <SearchResult>[];
    
    // البحث في أسماء الفئات
    for (final entry in categoryMap.entries) {
      final categoryName = _normalizeSearchText(entry.key);
      if (categoryName.contains(normalizedQuery) || 
          _isPartialMatch(categoryName, normalizedQuery)) {
        results.add(SearchResult.fromCategory(
          entry.key, 
          _getCategoryIcon(entry.key), 
          entry.value
        ));
      }
    }
    
    return results;
  }

  // التحقق من كون المتجر سوبرماركت
  bool _isSupermarket(Store store) {
    final name = store.name.toLowerCase();
    final category = store.category?.toLowerCase() ?? '';
    
    return name.contains('سوبرماركت') || 
           name.contains('هايبر') ||
           category.contains('سوبرماركت') ||
           category.contains('بقالة');
  }

  // الحصول على أيقونة الفئة
  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'مطاعم':
        return 'assets/icons/restaurant_category.png';
      case 'وجبات سريعة':
        return 'assets/icons/fast_food_category.png';
      case 'سوبرماركت':
        return 'assets/icons/supermarket_category.png';
      case 'بقالة':
        return 'assets/icons/grocery_category.png';
      default:
        return 'assets/icons/others_category.png';
    }
  }

  // بيانات تجريبية للمنتجات
  List<Product> _getMockProductsForStore(String storeId) {
    return [
      Product(
        id: '${storeId}_product_1',
        name: 'أرز بسمتي',
        description: 'أرز بسمتي عالي الجودة',
        price: 25.50,
        imageUrl: 'assets/images/rice.png',
        category: 'حبوب',
        brand: 'الأمل',
        unit: 'كيلو',
        storeId: storeId,
      ),
      Product(
        id: '${storeId}_product_2',
        name: 'حليب طازج',
        description: 'حليب طازج كامل الدسم',
        price: 8.75,
        imageUrl: 'assets/images/milk.png',
        category: 'ألبان',
        brand: 'المراعي',
        unit: 'لتر',
        storeId: storeId,
      ),
      Product(
        id: '${storeId}_product_3',
        name: 'خبز توست',
        description: 'خبز توست طري ولذيذ',
        price: 4.25,
        imageUrl: 'assets/images/bread.png',
        category: 'مخبوزات',
        brand: 'الطازج',
        unit: 'رغيف',
        storeId: storeId,
      ),
    ];
  }

  // بيانات تجريبية للعروض
  List<Offer> _getMockOffersForStore(String storeId, String storeName) {
    final now = DateTime.now();
    return [
      Offer(
        id: '${storeId}_offer_1',
        title: 'خصم 20% على جميع المنتجات',
        description: 'خصم كبير على جميع منتجات المتجر',
        imageUrl: 'assets/images/offer_banner.png',
        discountPercentage: 20,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 7)),
        storeId: storeId,
        storeName: storeName,
      ),
      Offer(
        id: '${storeId}_offer_2',
        title: 'شحن مجاني للطلبات فوق 50 ر.س',
        description: 'احصل على شحن مجاني',
        imageUrl: 'assets/images/free_delivery.png',
        discountPercentage: 0,
        minOrderAmount: 50,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 14)),
        storeId: storeId,
        storeName: storeName,
      ),
    ];
  }

  // البحث من الباك إند للجميع
  Future<List<SearchResult>> _searchBackendUniversal(
    String query, 
    List<SearchResultType> searchTypes,
    String? category, 
    double? latitude, 
    double? longitude
  ) async {
    final Map<String, dynamic> params = {
      'q': query,
      'lang': 'ar',
      'types': searchTypes.map((type) => type.toString().split('.').last).join(','),
    };

    if (category != null) params['category'] = category;
    if (latitude != null) params['lat'] = latitude.toString();
    if (longitude != null) params['lng'] = longitude.toString();

    final uri = Uri.parse('$baseUrl/search/universal').replace(
      queryParameters: params,
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = <SearchResult>[];
      
      // إضافة المتاجر
      if (data['stores'] != null) {
        for (final storeJson in data['stores']) {
          final store = Store.fromJson(storeJson);
          results.add(SearchResult.fromStore(store));
        }
      }
      
      // إضافة الأطباق
      if (data['dishes'] != null) {
        for (final dishData in data['dishes']) {
          final dish = Dish.fromJson(dishData['dish']);
          final storeId = dishData['store_id'];
          final storeName = dishData['store_name'];
          results.add(SearchResult.fromDish(dish, storeId, storeName));
        }
      }
      
      // إضافة المنتجات
      if (data['products'] != null) {
        for (final productData in data['products']) {
          final product = Product.fromJson(productData['product']);
          final storeName = productData['store_name'];
          results.add(SearchResult.fromProduct(product, storeName));
        }
      }
      
      // إضافة العروض
      if (data['offers'] != null) {
        for (final offerJson in data['offers']) {
          final offer = Offer.fromJson(offerJson);
          results.add(SearchResult.fromOffer(offer));
        }
      }
      
      return results;
    } else {
      throw Exception('فشل في البحث العام من الباك إند: ${response.statusCode}');
    }
  }
  Future<List<SearchResult>> searchMixed(String query, {
    List<Store>? localStores,
    String? category,
    double? latitude,
    double? longitude,
    int? limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    // التحقق من الكاش أولاً
    final cacheKey = 'mixed_$query${category ?? ''}${latitude ?? ''}${longitude ?? ''}';
    if (_mixedSearchCache.containsKey(cacheKey)) {
      return _mixedSearchCache[cacheKey]!;
    }

    final results = <SearchResult>[];
    
    // البحث المحلي أولاً للسرعة
    if (localStores != null) {
      final localResults = _searchLocalStores(query, localStores);
      results.addAll(localResults.map((store) => SearchResult.fromStore(store)));
      
      // البحث في الأطباق المحلية أيضاً
      final dishResults = _searchLocalDishes(query, localStores);
      results.addAll(dishResults);
    }

    try {
      // البحث من الباك إند للنتائج الإضافية
      final backendResults = await _searchBackend(query, category, latitude, longitude);
      
      // دمج النتائج وإزالة المكررات
      final seenIds = results.map((r) => r.id).toSet();
      for (final result in backendResults) {
        if (!seenIds.contains(result.id)) {
          results.add(result);
          seenIds.add(result.id);
        }
      }
    } catch (e) {
      debugPrint('خطأ في البحث من الباك إند: $e');
    }

    // ترتيب النتائج حسب الصلة
    _sortSearchResults(results, query);
    
    // تحديد النتائج حسب الحد المطلوب
    final finalResults = results.take(limit ?? 20).toList();
    
    // حفظ في الكاش
    _mixedSearchCache[cacheKey] = finalResults;
    
    return finalResults;
  }

  // البحث المحلي في المتاجر
  List<Store> _searchLocalStores(String query, List<Store> stores) {
    final normalizedQuery = _normalizeSearchText(query);
    
    return stores.where((store) {
      final storeName = _normalizeSearchText(store.name);
      final storeCategory = _normalizeSearchText(store.category ?? '');
      
      return storeName.contains(normalizedQuery) || 
             storeCategory.contains(normalizedQuery) ||
             _isPartialMatch(storeName, normalizedQuery) ||
             _isPartialMatch(storeCategory, normalizedQuery);
    }).toList();
  }

  // البحث المحلي في الأطباق
  List<SearchResult> _searchLocalDishes(String query, List<Store> stores) {
    final normalizedQuery = _normalizeSearchText(query);
    final results = <SearchResult>[];
    
    for (final store in stores) {
      // هنا نحتاج إلى بيانات الأطباق - سنستخدم أطباق تجريبية مؤقتاً
      final mockDishes = _getMockDishesForStore(store.id);
      
      for (final dish in mockDishes) {
        final dishName = _normalizeSearchText(dish.name);
        final dishDescription = _normalizeSearchText(dish.description);
        
        if (dishName.contains(normalizedQuery) || 
            dishDescription.contains(normalizedQuery) ||
            _isPartialMatch(dishName, normalizedQuery)) {
          results.add(SearchResult.fromDish(dish, store.id, store.name));
        }
      }
    }
    
    return results;
  }

  // أطباق تجريبية للمتجر - ستتم إزالتها عند ربط الباك إند
  List<Dish> _getMockDishesForStore(String storeId) {
    // إرجاع أطباق تجريبية بناءً على نوع المتجر
    return [
      Dish(
        id: '${storeId}_dish_1',
        name: 'برجر كلاسيك',
        imageUrls: ['assets/images/food_placeholder.png'],
        description: 'برجر لذيذ مع الجبن والخضار',
        likesPercent: 90,
        likesCount: 150,
        basePrice: 25.0,
        optionGroups: [],
      ),
      Dish(
        id: '${storeId}_dish_2',
        name: 'بيتزا مارجريتا',
        imageUrls: ['assets/images/food_placeholder.png'],
        description: 'بيتزا إيطالية تقليدية بالطماطم والجبن',
        likesPercent: 95,
        likesCount: 200,
        basePrice: 35.0,
        optionGroups: [],
      ),
      Dish(
        id: '${storeId}_dish_3',
        name: 'دجاج مقلي',
        imageUrls: ['assets/images/food_placeholder.png'],
        description: 'قطع دجاج مقلية ومقرمشة',
        likesPercent: 88,
        likesCount: 120,
        basePrice: 30.0,
        optionGroups: [],
      ),
    ];
  }

  // البحث من الباك إند
  Future<List<SearchResult>> _searchBackend(String query, String? category, double? latitude, double? longitude) async {
    final Map<String, dynamic> params = {
      'q': query,
      'lang': 'ar',
      'include_dishes': 'true', // طلب تضمين الأطباق في النتائج
    };

    if (category != null) params['category'] = category;
    if (latitude != null) params['lat'] = latitude.toString();
    if (longitude != null) params['lng'] = longitude.toString();

    final uri = Uri.parse('$baseUrl/search/mixed').replace(
      queryParameters: params,
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = <SearchResult>[];
      
      // إضافة المتاجر
      if (data['stores'] != null) {
        for (final storeJson in data['stores']) {
          final store = Store.fromJson(storeJson);
          results.add(SearchResult.fromStore(store));
        }
      }
      
      // إضافة الأطباق
      if (data['dishes'] != null) {
        for (final dishData in data['dishes']) {
          final dish = Dish.fromJson(dishData['dish']);
          final storeId = dishData['store_id'];
          final storeName = dishData['store_name'];
          results.add(SearchResult.fromDish(dish, storeId, storeName));
        }
      }
      
      return results;
    } else {
      throw Exception('فشل في البحث من الباك إند: ${response.statusCode}');
    }
  }

  // البحث الجغرافي المتقدم
  Future<List<SearchResult>> searchNearby(
    String query,
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
    List<SearchResultType>? searchTypes,
    String? category,
    int? limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    searchTypes ??= SearchResultType.values;

    try {
      final Map<String, dynamic> params = {
        'q': query,
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': (radiusKm * 1000).toString(), // تحويل إلى متر
        'lang': 'ar',
        'types': searchTypes.map((type) => type.toString().split('.').last).join(','),
        'limit': limit.toString(),
      };

      if (category != null) params['category'] = category;

      final uri = Uri.parse('$baseUrl/search/nearby').replace(
        queryParameters: params,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'ar',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseSearchResults(data);
      } else {
        throw Exception('فشل في البحث الجغرافي: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('خطأ في البحث الجغرافي: $e');
      return [];
    }
  }

  // البحث مع فلاتر متقدمة
  Future<List<SearchResult>> searchWithFilters(
    String query, {
    List<SearchResultType>? searchTypes,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? isOpen,
    bool? hasDelivery,
    bool? hasPickup,
    bool? hasOffers,
    String? sortBy, // 'relevance', 'distance', 'rating', 'price'
    double? latitude,
    double? longitude,
    int? limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    searchTypes ??= SearchResultType.values;

    try {
      final Map<String, dynamic> params = {
        'q': query,
        'lang': 'ar',
        'types': searchTypes.map((type) => type.toString().split('.').last).join(','),
        'limit': limit.toString(),
      };

      if (category != null) params['category'] = category;
      if (minPrice != null) params['min_price'] = minPrice.toString();
      if (maxPrice != null) params['max_price'] = maxPrice.toString();
      if (minRating != null) params['min_rating'] = minRating.toString();
      if (isOpen != null) params['is_open'] = isOpen.toString();
      if (hasDelivery != null) params['has_delivery'] = hasDelivery.toString();
      if (hasPickup != null) params['has_pickup'] = hasPickup.toString();
      if (hasOffers != null) params['has_offers'] = hasOffers.toString();
      if (sortBy != null) params['sort_by'] = sortBy;
      if (latitude != null) params['lat'] = latitude.toString();
      if (longitude != null) params['lng'] = longitude.toString();

      final uri = Uri.parse('$baseUrl/search/advanced').replace(
        queryParameters: params,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'ar',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseSearchResults(data);
      } else {
        throw Exception('فشل في البحث المتقدم: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('خطأ في البحث المتقدم: $e');
      return [];
    }
  }

  // تحليل نتائج البحث من الباك إند
  List<SearchResult> _parseSearchResults(Map<String, dynamic> data) {
    final results = <SearchResult>[];
    
    // إضافة المتاجر
    if (data['stores'] != null) {
      for (final storeJson in data['stores']) {
        try {
          final store = Store.fromJson(storeJson);
          results.add(SearchResult.fromStore(store));
        } catch (e) {
          debugPrint('خطأ في تحليل بيانات المتجر: $e');
        }
      }
    }
    
    // إضافة الأطباق
    if (data['dishes'] != null) {
      for (final dishData in data['dishes']) {
        try {
          final dish = Dish.fromJson(dishData['dish']);
          final storeId = dishData['store_id'];
          final storeName = dishData['store_name'];
          results.add(SearchResult.fromDish(dish, storeId, storeName));
        } catch (e) {
          debugPrint('خطأ في تحليل بيانات الطبق: $e');
        }
      }
    }
    
    // إضافة المنتجات
    if (data['products'] != null) {
      for (final productData in data['products']) {
        try {
          final product = Product.fromJson(productData['product']);
          final storeName = productData['store_name'];
          results.add(SearchResult.fromProduct(product, storeName));
        } catch (e) {
          debugPrint('خطأ في تحليل بيانات المنتج: $e');
        }
      }
    }
    
    // إضافة العروض
    if (data['offers'] != null) {
      for (final offerJson in data['offers']) {
        try {
          final offer = Offer.fromJson(offerJson);
          results.add(SearchResult.fromOffer(offer));
        } catch (e) {
          debugPrint('خطأ في تحليل بيانات العرض: $e');
        }
      }
    }
    
    return results;
  }

  // البحث الصوتي
  Future<String?> performVoiceSearch() async {
    try {
      // هنا يمكن إضافة مكتبة التعرف على الصوت
      // مثل speech_to_text package
      // final speechToText = SpeechToText();
      // final available = await speechToText.initialize();
      // if (available) {
      //   final result = await speechToText.listen();
      //   return result.recognizedWords;
      // }
      return null;
    } catch (e) {
      debugPrint('خطأ في البحث الصوتي: $e');
      return null;
    }
  }

  // اقتراحات البحث الذكية مع تعلم الآلة
  Future<List<String>> getSmartSuggestions(String query, {
    List<String>? userHistory,
    String? userLocation,
    String? timeOfDay,
  }) async {
    if (query.length < 2) return [];

    try {
      final Map<String, dynamic> params = {
        'q': query,
        'lang': 'ar',
      };

      if (userHistory != null && userHistory.isNotEmpty) {
        params['history'] = userHistory.join(',');
      }
      if (userLocation != null) params['location'] = userLocation;
      if (timeOfDay != null) params['time_of_day'] = timeOfDay;

      final response = await http.get(
        Uri.parse('$baseUrl/search/smart-suggestions').replace(
          queryParameters: params,
        ),
        headers: {
          'Accept-Language': 'ar',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['suggestions']);
      }
    } catch (e) {
      debugPrint('خطأ في جلب الاقتراحات الذكية: $e');
    }

    // اقتراحات محلية بسيطة كاحتياطي
    return _getLocalSuggestions(query);
  }

  // اقتراحات محلية بسيطة
  List<String> _getLocalSuggestions(String query) {
    final suggestions = <String>[];
    final normalizedQuery = _normalizeSearchText(query);
    
    // اقتراحات أساسية
    final baseSuggestions = [
      'برجر', 'بيتزا', 'دجاج', 'شاورما', 'سوشي', 'معجنات',
      'مشروبات', 'قهوة', 'حلويات', 'مأكولات بحرية', 'سلطات',
      'إفطار', 'غداء', 'عشاء', 'وجبات سريعة', 'مطعم صحي',
    ];
    
    for (final suggestion in baseSuggestions) {
      final normalizedSuggestion = _normalizeSearchText(suggestion);
      if (normalizedSuggestion.contains(normalizedQuery) || 
          normalizedQuery.contains(normalizedSuggestion)) {
        suggestions.add(suggestion);
      }
    }
    
    return suggestions.take(5).toList();
  }

  // البحث في الفئات مع إحصائيات
  Future<List<SearchResult>> searchCategories(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/categories?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Accept-Language': 'ar',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = <SearchResult>[];
        
        for (final categoryData in data['categories']) {
          results.add(SearchResult.fromCategory(
            categoryData['name'],
            categoryData['icon'] ?? 'assets/icons/others_category.png',
            categoryData['store_count'] ?? 0,
          ));
        }
        
        return results;
      }
    } catch (e) {
      debugPrint('خطأ في البحث في الفئات: $e');
    }
    
    return [];
  }

  // حفظ وتحليل تفاعلات المستخدم
  Future<void> logUserInteraction({
    required String query,
    required String resultId,
    required String action, // 'click', 'view', 'order', etc.
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/search/interactions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'query': query,
          'result_id': resultId,
          'action': action,
          'timestamp': DateTime.now().toIso8601String(),
          'metadata': metadata ?? {},
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      // تجاهل الأخطاء في الإحصائيات
      debugPrint('خطأ في تسجيل تفاعل المستخدم: $e');
    }
  }

  // الحصول على اتجاهات البحث
  Future<List<String>> getTrendingSearches({
    String? location,
    String? timeFrame = '24h', // '1h', '24h', '7d', '30d'
  }) async {
    try {
      final Map<String, dynamic> params = {
        'time_frame': timeFrame,
        'lang': 'ar',
      };
      
      if (location != null) params['location'] = location;

      final response = await http.get(
        Uri.parse('$baseUrl/search/trending').replace(
          queryParameters: params,
        ),
        headers: {
          'Accept-Language': 'ar',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['trending_searches']);
      }
    } catch (e) {
      debugPrint('خطأ في جلب الاتجاهات: $e');
    }

    // قائمة افتراضية للاتجاهات
    return [
      'وجبات صحية',
      'توصيل سريع',
      'عروض خاصة',
      'طعام عربي',
      'مطاعم جديدة',
    ];
  }

  // ============ Helper Methods ============

  /// تطبيع النص للبحث (إزالة التشكيل، الأحرف الخاصة، وتحويلها للأحرف الصغيرة)
  String _normalizeSearchText(String text) {
    if (text.isEmpty) return '';
    
    // إزالة التشكيل العربي
    String normalized = text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED]'), '')
        // تطبيع الألف
        .replaceAll('آ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('ى', 'ي')
        // إزالة الأحرف الخاصة والأرقام
        .replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFFa-zA-Z\s]'), '')
        // تحويل للأحرف الصغيرة
        .toLowerCase()
        // إزالة المسافات الزائدة
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    return normalized;
  }

  /// فحص التطابق الجزئي بين النصوص
  bool _isPartialMatch(String text, String query) {
    if (text.isEmpty || query.isEmpty) return false;
    
    final normalizedText = _normalizeSearchText(text);
    final normalizedQuery = _normalizeSearchText(query);
    
    // تطابق مباشر
    if (normalizedText.contains(normalizedQuery)) return true;
    
    // تطابق الكلمات
    final textWords = normalizedText.split(' ');
    final queryWords = normalizedQuery.split(' ');
    
    for (String queryWord in queryWords) {
      if (queryWord.isNotEmpty) {
        bool wordFound = false;
        for (String textWord in textWords) {
          if (textWord.startsWith(queryWord) || textWord.contains(queryWord)) {
            wordFound = true;
            break;
          }
        }
        if (!wordFound) return false;
      }
    }
    
    return true;
  }

  /// ترتيب نتائج البحث حسب الصلة
  void _sortSearchResults(List<SearchResult> results, String query) {
    if (results.isEmpty || query.isEmpty) return;
    
    final normalizedQuery = _normalizeSearchText(query);
    
    results.sort((a, b) {
      // حساب نقاط الصلة لكل نتيجة
      int scoreA = _calculateRelevanceScore(a, normalizedQuery);
      int scoreB = _calculateRelevanceScore(b, normalizedQuery);
      
      // ترتيب تنازلي (الأعلى نقاط أولاً)
      return scoreB.compareTo(scoreA);
    });
  }

  /// حساب نقاط الصلة للنتيجة
  int _calculateRelevanceScore(SearchResult result, String normalizedQuery) {
    int score = 0;
    final normalizedTitle = _normalizeSearchText(result.title);
    final normalizedSubtitle = _normalizeSearchText(result.subtitle);
    
    // التطابق المباشر في العنوان (نقاط عالية)
    if (normalizedTitle == normalizedQuery) {
      score += 100;
    } else if (normalizedTitle.startsWith(normalizedQuery)) {
      score += 80;
    } else if (normalizedTitle.contains(normalizedQuery)) {
      score += 60;
    }
    
    // التطابق في العنوان الفرعي
    if (normalizedSubtitle.contains(normalizedQuery)) {
      score += 30;
    }
    
    // نقاط إضافية حسب نوع النتيجة
    switch (result.type) {
      case SearchResultType.store:
        score += 20; // المطاعم لها أولوية
        break;
      case SearchResultType.dish:
        score += 15;
        break;
      case SearchResultType.offer:
        score += 25; // العروض لها أولوية عالية
        break;
      default:
        score += 10;
    }
    
    // نقاط حسب التقييم (إذا توفر في Store)
    if (result.store?.rating != null && result.store!.rating.isNotEmpty) {
      try {
        final ratingValue = double.parse(result.store!.rating);
        score += (ratingValue * 5).toInt();
      } catch (e) {
        // تجاهل الخطأ إذا لم يكن التقييم رقم صالح
      }
    }
    
    // نقاط إضافية للمتاجر المدعومة
    if (result.store?.sponsored == true) score += 15;
    
    return score;
  }
}

// مثيل عام للخدمة
final SearchService searchService = SearchService();
