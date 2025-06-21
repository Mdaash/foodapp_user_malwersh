// lib/services/image_cache_service.dart

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheService {
  static const String _cacheKey = 'foodAppImageCache';
  
  // إعداد مدير الكاش المخصص
  static final CacheManager _customCacheManager = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 7),    // فترة انتهاء الكاش: 7 أيام
      maxNrOfCacheObjects: 1000,               // الحد الأقصى للملفات المخزنة
      repo: JsonCacheInfoRepository(databaseName: _cacheKey),
      fileService: HttpFileService(),
    ),
  );

  // إعداد مدير كاش عالي الأداء للصور الأساسية
  static final CacheManager _criticalCacheManager = CacheManager(
    Config(
      'criticalImageCache',
      stalePeriod: const Duration(days: 30),   // كاش أطول للصور المهمة
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'criticalImageCache'),
      fileService: HttpFileService(),
    ),
  );

  // الحصول على مدير الكاش المخصص
  static CacheManager get customCacheManager => _customCacheManager;
  
  // الحصول على مدير الكاش للصور المهمة
  static CacheManager get criticalCacheManager => _criticalCacheManager;

  // تحسين رابط الصور مع CDN parameters
  static String optimizeImageUrl(String imageUrl, {
    int? width,
    int? height,
    int quality = 80,
    String format = 'webp',
  }) {
    // إذا كان الرابط يحتوي على معاملات CDN، نضيف تحسينات
    if (imageUrl.contains('cloudinary.com') || 
        imageUrl.contains('imagekit.io') ||
        imageUrl.contains('cloudflare.com')) {
      
      String optimizedUrl = imageUrl;
      
      // إضافة معاملات الحجم والجودة حسب نوع CDN
      if (imageUrl.contains('cloudinary.com')) {
        // Cloudinary optimization
        String transformation = 'f_$format,q_$quality';
        if (width != null && height != null) {
          transformation += ',w_$width,h_$height,c_fill';
        } else if (width != null) {
          transformation += ',w_$width';
        } else if (height != null) {
          transformation += ',h_$height';
        }
        
        optimizedUrl = imageUrl.replaceFirst(
          '/upload/',
          '/upload/$transformation/',
        );
      } else if (imageUrl.contains('imagekit.io')) {
        // ImageKit optimization
        String params = '?tr=q-$quality,f-$format';
        if (width != null && height != null) {
          params += ',w-$width,h-$height,c-maintain_ratio';
        }
        optimizedUrl = imageUrl + params;
      }
      
      return optimizedUrl;
    }
    
    return imageUrl;
  }

  // تنظيف الكاش
  static Future<void> clearCache() async {
    await _customCacheManager.emptyCache();
    await _criticalCacheManager.emptyCache();
  }

  // الحصول على معلومات الكاش المبسطة
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      // نحصل على معلومات بسيطة عن الكاش
      return {
        'status': 'active',
        'custom_cache': 'Standard 7-day cache',
        'critical_cache': 'Critical 30-day cache',
        'cache_managers': 2,
        'optimization': 'CDN parameters enabled',
      };
    } catch (e) {
      return {
        'error': 'Failed to get cache info: $e',
        'status': 'error',
      };
    }
  }

  // تحميل مسبق للصور المهمة
  static Future<void> preloadCriticalImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      try {
        await _criticalCacheManager.downloadFile(url);
      } catch (e) {
        print('فشل في التحميل المسبق للصورة: $url - $e');
      }
    }
  }

  // الصور المهمة للتطبيق (شعارات، أيقونات، إلخ)
  static const List<String> criticalImages = [
    // يمكن إضافة روابط الصور المهمة هنا
    // 'https://example.com/logo.png',
    // 'https://example.com/default-avatar.png',
  ];

  // تهيئة الكاش عند بدء التطبيق
  static Future<void> initializeCache() async {
    try {
      // تحميل مسبق للصور المهمة
      if (criticalImages.isNotEmpty) {
        await preloadCriticalImages(criticalImages);
      }
      
      print('✅ Image cache service initialized successfully');
    } catch (e) {
      print('⚠️ Warning: Image cache initialization error: $e');
    }
  }
}
