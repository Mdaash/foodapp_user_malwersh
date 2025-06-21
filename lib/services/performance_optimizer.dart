// lib/services/performance_optimizer.dart
// تحسين أداء Flutter مع مراقبة الأداء

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'image_cache_service.dart';

class PerformanceOptimizer {
  // تحسين الذاكرة
  static Future<void> optimizeMemory() async {
    try {
      // تنظيف كاش الصور
      await ImageCacheService.clearCache();
      
      // تشغيل Garbage Collector
      if (kDebugMode) {
        print('🧹 تنظيف الذاكرة...');
      }
      
      // تنظيف كاش Flutter
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تحسين الذاكرة: $e');
      }
    }
  }
  
  // تحسين حجم كاش الصور
  static void optimizeImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    // تعيين حد أقصى للذاكرة (100 MB)
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    
    // تعيين حد أقصى للصور (1000 صورة)
    imageCache.maximumSize = 1000;
    
    if (kDebugMode) {
      print('✅ تم تحسين إعدادات كاش الصور');
    }
  }
  
  // مراقبة الأداء
  static Map<String, dynamic> getPerformanceStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    return {
      'image_cache': {
        'current_size': imageCache.currentSize,
        'current_size_bytes': imageCache.currentSizeBytes,
        'max_size': imageCache.maximumSize,
        'max_size_bytes': imageCache.maximumSizeBytes,
        'live_images': imageCache.liveImageCount,
        'pending_images': imageCache.pendingImageCount,
      },
      'memory': {
        'usage_mb': (imageCache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'max_mb': (imageCache.maximumSizeBytes / (1024 * 1024)).toStringAsFixed(2),
      }
    };
  }
  
  // تهيئة التحسينات
  static Future<void> initialize() async {
    optimizeImageCache();
    
    // تحميل مسبق للصور المهمة
    await ImageCacheService.initializeCache();
    
    if (kDebugMode) {
      print('🚀 تم تهيئة محسن الأداء');
    }
  }
}
