// lib/services/enhanced_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_optimization_service.dart';
import 'advanced_cache_service.dart';

class EnhancedApiService with ApiOptimizationMixin {
  static final EnhancedApiService _instance = EnhancedApiService._internal();
  factory EnhancedApiService() => _instance;
  EnhancedApiService._internal();

  // خدمات التحسين
  static final AdvancedCacheService _cache = AdvancedCacheService();
  static bool _isInitialized = false;

  // إعدادات API
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8080"; // للويب
    } else {
      return "http://10.0.2.2:8080"; // للمحاكي
    }
  }

  // تهيئة الخدمات
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await _cache.init();
      _isInitialized = true;
      debugPrint('🚀 Enhanced API Service initialized');
    }
  }

  // GET مع تحسينات
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool useCache = true,
    bool useDeduplication = true,
    Duration cacheDuration = const Duration(minutes: 5),
    RequestPriority priority = RequestPriority.normal,
  }) async {
    return optimizedRequest(
      endpoint,
      () => _performGet(endpoint, queryParams),
      useCache: useCache,
      useDeduplication: useDeduplication,
      cacheDuration: cacheDuration,
      priority: priority,
    );
  }

  // POST مع تحسينات
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool useDeduplication = false,
    RequestPriority priority = RequestPriority.high,
  }) async {
    return optimizedRequest(
      '${endpoint}_post',
      () => _performPost(endpoint, body),
      useCache: false,
      useDeduplication: useDeduplication,
      priority: priority,
    );
  }

  // PUT مع تحسينات
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    RequestPriority priority = RequestPriority.high,
  }) async {
    return optimizedRequest(
      '${endpoint}_put',
      () => _performPut(endpoint, body),
      useCache: false,
      useDeduplication: false,
      priority: priority,
    );
  }

  // DELETE مع تحسينات
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    RequestPriority priority = RequestPriority.high,
  }) async {
    return optimizedRequest(
      '${endpoint}_delete',
      () => _performDelete(endpoint),
      useCache: false,
      useDeduplication: false,
      priority: priority,
    );
  }

  // تنفيذ GET الفعلي
  Future<Map<String, dynamic>> _performGet(
    String endpoint,
    Map<String, dynamic>? queryParams,
  ) async {
    try {
      String url = '$baseUrl$endpoint';
      
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        url += '?$queryString';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تنفيذ POST الفعلي
  Future<Map<String, dynamic>> _performPost(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تنفيذ PUT الفعلي
  Future<Map<String, dynamic>> _performPut(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تنفيذ DELETE الفعلي
  Future<Map<String, dynamic>> _performDelete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Headers الافتراضية
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'FoodApp/1.0',
    };
  }

  // معالجة الاستجابة
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException('Invalid JSON response', response.statusCode);
      }
    } else {
      throw ApiException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        response.statusCode,
      );
    }
  }

  // معالجة الأخطاء
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else {
      return ApiException('Network error: $error', 0);
    }
  }

  // تحميل مجمع للبيانات
  Future<List<T>> batchLoadData<T>(
    String batchType,
    List<String> ids,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (ids.isEmpty) return [];

    final results = await batchLoad<Map<String, dynamic>>(
      batchType,
      ids.first,
      (batchIds) => _batchFetch(batchType, batchIds),
    );

    return results.map(fromJson).toList();
  }

  // تحميل مجمع داخلي
  Future<List<Map<String, dynamic>>> _batchFetch(
    String batchType,
    List<String> ids,
  ) async {
    final response = await post('/api/batch/$batchType', body: {'ids': ids});
    
    if (response['status'] == 'success') {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    
    throw ApiException('Batch fetch failed', 500);
  }

  // طلبات متوازية مع حد أقصى
  Future<List<T>> parallelRequests<T>(
    List<Future<T> Function()> requestFunctions, {
    int maxConcurrency = 5,
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < requestFunctions.length; i += maxConcurrency) {
      final batch = requestFunctions
          .skip(i)
          .take(maxConcurrency)
          .map((fn) => fn())
          .toList();
      
      final batchResults = await Future.wait(batch);
      results.addAll(batchResults);
    }
    
    return results;
  }

  // إحصائيات الأداء
  Map<String, dynamic> getPerformanceStats() {
    return {
      'cache_stats': _cache.getStats(),
      'base_url': baseUrl,
      'is_initialized': _isInitialized,
    };
  }

  // تنظيف الموارد
  void dispose() {
    _cache.dispose();
  }
}

// استثناء API مخصص
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ميزات إضافية للـ API
extension ApiServiceExtensions on EnhancedApiService {
  // تحميل صفحات متعددة
  Future<List<T>> loadMultiplePages<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    int maxPages = 5,
    int itemsPerPage = 20,
    Map<String, dynamic>? filters,
  }) async {
    final allItems = <T>[];
    
    for (int page = 1; page <= maxPages; page++) {
      final queryParams = {
        'page': page,
        'limit': itemsPerPage,
        ...?filters,
      };
      
      final response = await get(endpoint, queryParams: queryParams);
      
      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final items = data['items'] as List;
        
        if (items.isEmpty) break;
        
        allItems.addAll(items.map((json) => fromJson(json)));
        
        // إذا كانت العناصر أقل من المطلوب، فهذه آخر صفحة
        if (items.length < itemsPerPage) break;
      } else {
        break;
      }
    }
    
    return allItems;
  }

  // بحث ذكي مع اقتراحات
  Future<SearchResult<T>> smartSearch<T>(
    String query,
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'search': query,
      'suggestions': true,
      ...?filters,
    };
    
    final response = await get(endpoint, queryParams: queryParams);
    
    if (response['status'] == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      
      return SearchResult(
        results: (data['items'] as List).map((json) => fromJson(json)).toList(),
        suggestions: List<String>.from(data['suggestions'] ?? []),
        totalCount: data['total_count'] ?? 0,
        searchTime: data['search_time'] ?? 0,
      );
    }
    
    throw ApiException('Search failed', 500);
  }
}

// نتيجة البحث
class SearchResult<T> {
  final List<T> results;
  final List<String> suggestions;
  final int totalCount;
  final int searchTime;

  SearchResult({
    required this.results,
    required this.suggestions,
    required this.totalCount,
    required this.searchTime,
  });
}
