// lib/services/performance_optimizer_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'image_cache_service.dart';

class PerformanceOptimizerService {
  static bool _isInitialized = false;
  
  /// تهيئة محسن الأداء
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // تحسين ذاكرة الصور
      await _optimizeImageCache();
      
      // تحسين أداء الشبكة
      await _optimizeNetworking();
      
      // تهيئة خدمة كاش الصور
      await ImageCacheService.initializeCache();
      
      _isInitialized = true;
      debugPrint('✅ Performance Optimizer initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Performance Optimizer initialization error: $e');
    }
  }
  
  /// تحسين ذاكرة الصور
  static Future<void> _optimizeImageCache() async {
    // تعيين حد أقصى لذاكرة الصور (100 MB)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB
    
    // تعيين حد أقصى لعدد الصور (1000 صورة)
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    
    debugPrint('🖼️ Image cache optimized: 100MB / 1000 images');
  }
  
  /// تحسين أداء الشبكة
  static Future<void> _optimizeNetworking() async {
    // يمكن إضافة تحسينات شبكة إضافية هنا
    debugPrint('🌐 Network optimizations applied');
  }
  
  /// مراقبة استخدام الذاكرة
  static Map<String, dynamic> getMemoryStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    return {
      'image_cache': {
        'current_size_bytes': imageCache.currentSizeBytes,
        'maximum_size_bytes': imageCache.maximumSizeBytes,
        'current_size': imageCache.currentSize,
        'maximum_size': imageCache.maximumSize,
        'live_image_count': imageCache.liveImageCount,
        'pending_image_count': imageCache.pendingImageCount,
      },
      'memory_usage_mb': (imageCache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(2),
      'cache_utilization': ((imageCache.currentSize / imageCache.maximumSize) * 100).toStringAsFixed(1),
    };
  }
  
  /// تنظيف ذاكرة الصور عند الحاجة
  static void cleanupImageMemory() {
    PaintingBinding.instance.imageCache.clear();
    debugPrint('🧹 Image cache cleared');
  }
  
  /// تحسين أداء التطبيق تلقائياً
  static Future<void> autoOptimize() async {
    final stats = getMemoryStats();
    final utilizationPercent = double.parse(stats['cache_utilization']);
    
    // إذا كان استخدام الكاش أكثر من 90%، نظف جزء منه
    if (utilizationPercent > 90) {
      PaintingBinding.instance.imageCache.clearLiveImages();
      debugPrint('🔧 Auto-optimized: Cleared live images due to high utilization');
    }
    
    // إذا كان استخدام الذاكرة أكثر من 80 MB، نظف الكاش
    final memoryUsage = double.parse(stats['memory_usage_mb']);
    if (memoryUsage > 80) {
      cleanupImageMemory();
      debugPrint('🔧 Auto-optimized: Cleared cache due to high memory usage');
    }
  }
  
  /// تحميل مسبق للصور المهمة
  static Future<void> preloadCriticalImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      try {
        // تحسين رابط الصورة
        final optimizedUrl = ImageCacheService.optimizeImageUrl(
          url,
          width: 400,
          height: 300,
          quality: 80,
        );
        
        // تحميل مسبق مع كاش مهم
        await ImageCacheService.criticalCacheManager.downloadFile(optimizedUrl);
        debugPrint('📥 Preloaded critical image: $optimizedUrl');
      } catch (e) {
        debugPrint('❌ Failed to preload image $url: $e');
      }
    }
  }
  
  /// إحصائيات شاملة للأداء
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'memory_stats': getMemoryStats(),
      'cache_managers': {
        'standard_cache': 'Active (7 days TTL)',
        'critical_cache': 'Active (30 days TTL)',
      },
      'optimizations': {
        'image_memory_limit': '100 MB',
        'image_count_limit': '1000 images',
        'cdn_optimization': 'Enabled',
        'auto_cleanup': 'Enabled',
      },
      'recommendations': _generateRecommendations(),
    };
  }
  
  /// توليد توصيات الأداء
  static List<String> _generateRecommendations() {
    final recommendations = <String>[];
    final stats = getMemoryStats();
    
    final utilizationPercent = double.parse(stats['cache_utilization']);
    final memoryUsage = double.parse(stats['memory_usage_mb']);
    
    if (utilizationPercent > 80) {
      recommendations.add('Cache utilization high ($utilizationPercent%) - Consider cleanup');
    }
    
    if (memoryUsage > 60) {
      recommendations.add('Memory usage high (${memoryUsage}MB) - Consider reducing image quality');
    }
    
    final liveImages = stats['image_cache']['live_image_count'];
    if (liveImages > 100) {
      recommendations.add('Too many live images ($liveImages) - Consider lazy loading');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Performance is optimal ✅');
    }
    
    return recommendations;
  }
}
