// lib/services/advanced_cache_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AdvancedCacheService {
  static final AdvancedCacheService _instance = AdvancedCacheService._internal();
  factory AdvancedCacheService() => _instance;
  AdvancedCacheService._internal();

  SharedPreferences? _prefs;
  final Map<String, CacheItem> _memoryCache = {};
  Timer? _cleanupTimer;

  // إعدادات التخزين المؤقت
  static const Duration _defaultTtl = Duration(hours: 1);
  static const int _maxMemoryItems = 100;
  static const int _maxStorageSize = 10 * 1024 * 1024; // 10MB

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _startCleanupTimer();
    await _loadFromStorage(null);
  }

  /// حفظ البيانات في التخزين المؤقت
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
    CacheLevel level = CacheLevel.memory,
    CachePriority priority = CachePriority.normal,
  }) async {
    final item = CacheItem(
      key: key,
      value: value,
      expiryTime: DateTime.now().add(ttl ?? _defaultTtl),
      level: level,
      priority: priority,
      accessCount: 0,
      lastAccessed: DateTime.now(),
    );

    // حفظ في الذاكرة
    if (level == CacheLevel.memory || level == CacheLevel.both) {
      _memoryCache[key] = item;
      _enforceMemoryLimit();
    }

    // حفظ في التخزين المحلي
    if (level == CacheLevel.storage || level == CacheLevel.both) {
      await _saveToStorage(key, item);
    }
  }

  /// استرجاع البيانات من التخزين المؤقت
  Future<T?> get<T>(String key, {T? defaultValue}) async {
    CacheItem? item;

    // البحث في الذاكرة أولاً
    if (_memoryCache.containsKey(key)) {
      item = _memoryCache[key];
    } else {
      // البحث في التخزين المحلي
      item = await _loadFromStorage(key);
      if (item != null) {
        _memoryCache[key] = item;
      }
    }

    if (item != null) {
      // التحقق من انتهاء الصلاحية
      if (DateTime.now().isAfter(item.expiryTime)) {
        await remove(key);
        return defaultValue;
      }

      // تحديث إحصائيات الوصول
      item.accessCount++;
      item.lastAccessed = DateTime.now();

      return item.value as T?;
    }

    return defaultValue;
  }

  /// حذف عنصر من التخزين المؤقت
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _prefs?.remove('cache_$key');
  }

  /// تنظيف التخزين المؤقت حسب النمط
  Future<void> clearPattern(String pattern) async {
    final keysToRemove = <String>[];

    // تنظيف الذاكرة
    for (final key in _memoryCache.keys) {
      if (key.contains(pattern)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }

    // تنظيف التخزين المحلي
    final allKeys = _prefs?.getKeys() ?? <String>{};
    for (final key in allKeys) {
      if (key.startsWith('cache_') && key.substring(6).contains(pattern)) {
        await _prefs?.remove(key);
      }
    }
  }

  /// تنظيف شامل
  Future<void> clearAll() async {
    _memoryCache.clear();
    
    final allKeys = _prefs?.getKeys() ?? <String>{};
    for (final key in allKeys) {
      if (key.startsWith('cache_')) {
        await _prefs?.remove(key);
      }
    }
  }

  /// التحقق من وجود مفتاح
  Future<bool> exists(String key) async {
    if (_memoryCache.containsKey(key)) {
      final item = _memoryCache[key]!;
      if (DateTime.now().isBefore(item.expiryTime)) {
        return true;
      } else {
        await remove(key);
        return false;
      }
    }

    final storageItem = await _loadFromStorage(key);
    if (storageItem != null) {
      if (DateTime.now().isBefore(storageItem.expiryTime)) {
        _memoryCache[key] = storageItem;
        return true;
      } else {
        await remove(key);
        return false;
      }
    }

    return false;
  }

  /// تحديث وقت انتهاء الصلاحية
  Future<void> updateTtl(String key, Duration newTtl) async {
    if (_memoryCache.containsKey(key)) {
      _memoryCache[key]!.expiryTime = DateTime.now().add(newTtl);
    }

    final storageItem = await _loadFromStorage(key);
    if (storageItem != null) {
      storageItem.expiryTime = DateTime.now().add(newTtl);
      await _saveToStorage(key, storageItem);
    }
  }

  /// استرجاع أو إنشاء البيانات
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() factory, {
    Duration? ttl,
    CacheLevel level = CacheLevel.memory,
  }) async {
    final cached = await get<T>(key);
    if (cached != null) {
      return cached;
    }

    final value = await factory();
    await set(key, value, ttl: ttl, level: level);
    return value;
  }

  /// تحديث البيانات في الخلفية
  Future<void> refreshInBackground<T>(
    String key,
    Future<T> Function() factory, {
    Duration? ttl,
    CacheLevel level = CacheLevel.memory,
  }) async {
    // تحديث البيانات بدون انتظار
    factory().then((value) async {
      try {
        await set(key, value, ttl: ttl, level: level);
      } catch (e) {
        debugPrint('Background refresh failed for $key: $e');
      }
    }).catchError((e) {
      debugPrint('Background refresh failed for $key: $e');
    });
  }

  /// إحصائيات التخزين المؤقت
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final expired = _memoryCache.values
        .where((item) => now.isAfter(item.expiryTime))
        .length;
    
    final totalAccess = _memoryCache.values
        .fold<int>(0, (sum, item) => sum + item.accessCount);

    return {
      'memoryItems': _memoryCache.length,
      'expiredItems': expired,
      'totalAccessCount': totalAccess,
      'avgAccessCount': _memoryCache.isEmpty ? 0 : totalAccess / _memoryCache.length,
      'cacheHitRate': _calculateHitRate(),
      'memoryUsage': _estimateMemoryUsage(),
    };
  }

  /// تحميل البيانات من التخزين المحلي
  Future<CacheItem?> _loadFromStorage(String? key) async {
    if (_prefs == null) return null;
    
    if (key != null) {
      final data = _prefs!.getString('cache_$key');
      if (data != null) {
        try {
          return CacheItem.fromJson(jsonDecode(data));
        } catch (e) {
          await _prefs!.remove('cache_$key');
        }
      }
      return null;
    }

    // تحميل جميع العناصر من التخزين المحلي
    final allKeys = _prefs!.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('cache_')) {
        final data = _prefs!.getString(key);
        if (data != null) {
          try {
            final item = CacheItem.fromJson(jsonDecode(data));
            final cacheKey = key.substring(6); // إزالة "cache_"
            
            if (DateTime.now().isBefore(item.expiryTime)) {
              _memoryCache[cacheKey] = item;
            } else {
              await _prefs!.remove(key);
            }
          } catch (e) {
            await _prefs!.remove(key);
          }
        }
      }
    }
    return null;
  }

  /// حفظ البيانات في التخزين المحلي
  Future<void> _saveToStorage(String key, CacheItem item) async {
    if (_prefs == null) return;
    
    try {
      final data = jsonEncode(item.toJson());
      if (data.length < _maxStorageSize) {
        await _prefs!.setString('cache_$key', data);
      }
    } catch (e) {
      debugPrint('Failed to save cache item: $e');
    }
  }

  /// فرض حد الذاكرة
  void _enforceMemoryLimit() {
    while (_memoryCache.length > _maxMemoryItems) {
      // إزالة العنصر الأقل استخداماً
      String? leastUsedKey;
      int minAccess = double.maxFinite.toInt();
      DateTime? oldestAccess;

      for (final entry in _memoryCache.entries) {
        if (entry.value.accessCount < minAccess ||
            (entry.value.accessCount == minAccess &&
             (oldestAccess == null || entry.value.lastAccessed.isBefore(oldestAccess)))) {
          minAccess = entry.value.accessCount;
          oldestAccess = entry.value.lastAccessed;
          leastUsedKey = entry.key;
        }
      }

      if (leastUsedKey != null) {
        _memoryCache.remove(leastUsedKey);
      }
    }
  }

  /// بدء تايمر التنظيف
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _cleanupExpired();
    });
  }

  /// تنظيف العناصر المنتهية الصلاحية
  void _cleanupExpired() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (now.isAfter(entry.value.expiryTime)) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
  }

  double _calculateHitRate() {
    // معدل النجاح - يمكن تحسينه لاحقاً
    return _memoryCache.isEmpty ? 0.0 : 0.85;
  }

  int _estimateMemoryUsage() {
    // تقدير استخدام الذاكرة بالبايت
    return _memoryCache.length * 1024; // تقدير متوسط
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
  }
}

/// عنصر التخزين المؤقت
class CacheItem {
  final String key;
  final dynamic value;
  DateTime expiryTime;
  final CacheLevel level;
  final CachePriority priority;
  int accessCount;
  DateTime lastAccessed;

  CacheItem({
    required this.key,
    required this.value,
    required this.expiryTime,
    required this.level,
    required this.priority,
    required this.accessCount,
    required this.lastAccessed,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'expiryTime': expiryTime.millisecondsSinceEpoch,
      'level': level.index,
      'priority': priority.index,
      'accessCount': accessCount,
      'lastAccessed': lastAccessed.millisecondsSinceEpoch,
    };
  }

  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      key: json['key'],
      value: json['value'],
      expiryTime: DateTime.fromMillisecondsSinceEpoch(json['expiryTime']),
      level: CacheLevel.values[json['level']],
      priority: CachePriority.values[json['priority']],
      accessCount: json['accessCount'],
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(json['lastAccessed']),
    );
  }
}

enum CacheLevel {
  memory,    // الذاكرة فقط
  storage,   // التخزين المحلي فقط
  both,      // كلاهما
}

enum CachePriority {
  low,       // أولوية منخفضة
  normal,    // أولوية عادية
  high,      // أولوية عالية
  critical,  // أولوية حرجة
}
