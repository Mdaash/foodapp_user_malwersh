// lib/services/api_optimization_service.dart
import 'dart:async';

class ApiOptimizationService {
  static final ApiOptimizationService _instance = ApiOptimizationService._internal();
  factory ApiOptimizationService() => _instance;
  ApiOptimizationService._internal();

  // Request Deduplication - منع الطلبات المكررة
  final Map<String, Future<dynamic>> _pendingRequests = {};
  
  // Batch Loading - تجميع الطلبات
  final Map<String, List<String>> _batchQueues = {};
  final Map<String, Timer> _batchTimers = {};
  
  // Response Caching - تخزين الاستجابات مؤقتاً
  final Map<String, CachedResponse> _responseCache = {};
  
  // Request Priority Queue - أولوية الطلبات
  final List<ApiRequest> _priorityQueue = [];

  /// منع الطلبات المكررة - Request Deduplication
  Future<T> deduplicateRequest<T>(
    String key, 
    Future<T> Function() requestFunction,
  ) async {
    // إذا كان الطلب قيد التنفيذ، انتظر النتيجة
    if (_pendingRequests.containsKey(key)) {
      return await _pendingRequests[key] as T;
    }

    // تنفيذ الطلب وحفظه في الذاكرة المؤقتة
    final future = requestFunction();
    _pendingRequests[key] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _pendingRequests.remove(key);
    }
  }

  /// تجميع الطلبات - Batch Loading
  Future<List<T>> batchRequest<T>(
    String batchKey,
    String itemId,
    Future<List<T>> Function(List<String> ids) batchFunction, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final completer = Completer<List<T>>();
    
    // إضافة العنصر للطابور
    _batchQueues.putIfAbsent(batchKey, () => []).add(itemId);
    
    // إلغاء التايمر السابق وإنشاء جديد
    _batchTimers[batchKey]?.cancel();
    _batchTimers[batchKey] = Timer(delay, () async {
      final ids = _batchQueues[batchKey] ?? [];
      if (ids.isEmpty) return;
      
      try {
        final results = await batchFunction(ids);
        completer.complete(results);
      } catch (e) {
        completer.completeError(e);
      } finally {
        _batchQueues.remove(batchKey);
        _batchTimers.remove(batchKey);
      }
    });

    return completer.future;
  }

  /// تخزين الاستجابات المؤقت - Response Caching
  Future<T> cachedRequest<T>(
    String cacheKey,
    Future<T> Function() requestFunction, {
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    final now = DateTime.now();
    
    // التحقق من وجود استجابة مخزنة وصالحة
    if (_responseCache.containsKey(cacheKey)) {
      final cached = _responseCache[cacheKey]!;
      if (now.isBefore(cached.expiryTime)) {
        return cached.data as T;
      } else {
        _responseCache.remove(cacheKey);
      }
    }

    // تنفيذ الطلب وحفظ النتيجة
    final result = await requestFunction();
    _responseCache[cacheKey] = CachedResponse(
      data: result,
      expiryTime: now.add(cacheDuration),
    );

    return result;
  }

  /// نظام أولوية الطلبات - Priority Queue
  Future<T> priorityRequest<T>(
    ApiRequest request,
    Future<T> Function() requestFunction,
  ) async {
    final completer = Completer<T>();
    
    request.completer = completer;
    request.requestFunction = requestFunction;
    
    // إضافة الطلب للطابور حسب الأولوية
    _insertByPriority(request);
    
    // معالجة الطلبات إذا لم تكن قيد التنفيذ
    _processQueue();
    
    return completer.future;
  }

  void _insertByPriority(ApiRequest request) {
    int insertIndex = _priorityQueue.length;
    for (int i = 0; i < _priorityQueue.length; i++) {
      if (_priorityQueue[i].priority.index > request.priority.index) {
        insertIndex = i;
        break;
      }
    }
    _priorityQueue.insert(insertIndex, request);
  }

  bool _isProcessing = false;
  
  Future<void> _processQueue() async {
    if (_isProcessing || _priorityQueue.isEmpty) return;
    
    _isProcessing = true;
    
    while (_priorityQueue.isNotEmpty) {
      final request = _priorityQueue.removeAt(0);
      
      try {
        final result = await request.requestFunction!();
        request.completer!.complete(result);
      } catch (e) {
        request.completer!.completeError(e);
      }
    }
    
    _isProcessing = false;
  }

  /// تنظيف الذاكرة المؤقتة
  void clearCache({String? pattern}) {
    if (pattern != null) {
      _responseCache.removeWhere((key, value) => key.contains(pattern));
    } else {
      _responseCache.clear();
    }
  }

  /// إحصائيات الأداء
  Map<String, dynamic> getPerformanceStats() {
    final now = DateTime.now();
    final activeCacheCount = _responseCache.values
        .where((cached) => now.isBefore(cached.expiryTime))
        .length;

    return {
      'pendingRequests': _pendingRequests.length,
      'batchQueues': _batchQueues.length,
      'activeCacheEntries': activeCacheCount,
      'totalCacheEntries': _responseCache.length,
      'queuedRequests': _priorityQueue.length,
      'isProcessingQueue': _isProcessing,
    };
  }

  /// تنظيف عام للخدمة
  void dispose() {
    _pendingRequests.clear();
    _batchQueues.clear();
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();
    _responseCache.clear();
    _priorityQueue.clear();
  }
}

class CachedResponse {
  final dynamic data;
  final DateTime expiryTime;

  CachedResponse({
    required this.data,
    required this.expiryTime,
  });
}

class ApiRequest {
  final String id;
  final RequestPriority priority;
  final Map<String, dynamic> metadata;
  
  Completer? completer;
  Function? requestFunction;

  ApiRequest({
    required this.id,
    this.priority = RequestPriority.normal,
    this.metadata = const {},
  });
}

enum RequestPriority {
  critical,  // طلبات حرجة (المصادقة، الدفع)
  high,      // طلبات مهمة (بيانات المستخدم، السلة)
  normal,    // طلبات عادية (قوائم المطاعم)
  low,       // طلبات أقل أهمية (الإحصائيات)
  background // طلبات خلفية (التحليلات)
}

/// مزج API Optimization مع أي خدمة API موجودة
mixin ApiOptimizationMixin {
  final ApiOptimizationService _optimizer = ApiOptimizationService();

  Future<T> optimizedRequest<T>(
    String endpoint,
    Future<T> Function() requestFunction, {
    bool useDeduplication = true,
    bool useCache = true,
    Duration cacheDuration = const Duration(minutes: 5),
    RequestPriority priority = RequestPriority.normal,
  }) async {
    final key = 'api_$endpoint';

    if (useCache && useDeduplication) {
      return _optimizer.cachedRequest(
        key,
        () => _optimizer.deduplicateRequest(key, requestFunction),
        cacheDuration: cacheDuration,
      );
    } else if (useCache) {
      return _optimizer.cachedRequest(key, requestFunction, cacheDuration: cacheDuration);
    } else if (useDeduplication) {
      return _optimizer.deduplicateRequest(key, requestFunction);
    } else if (priority != RequestPriority.normal) {
      return _optimizer.priorityRequest(
        ApiRequest(id: key, priority: priority),
        requestFunction,
      );
    } else {
      return requestFunction();
    }
  }

  Future<List<T>> batchLoad<T>(
    String batchType,
    String itemId,
    Future<List<T>> Function(List<String> ids) batchFunction,
  ) {
    return _optimizer.batchRequest(batchType, itemId, batchFunction);
  }
}
