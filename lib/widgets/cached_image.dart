import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_cache_service.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Duration fadeInDuration;
  final Duration placeholderFadeInDuration;
  final bool isCritical; // للصور المهمة
  final bool enableOptimization; // تفعيل تحسين CDN

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
    this.isCritical = false,
    this.enableOptimization = true,
  });

  @override
  Widget build(BuildContext context) {
    // تحسين رابط الصورة إذا كان مفعلاً
    String optimizedUrl = imageUrl;
    if (enableOptimization) {
      optimizedUrl = ImageCacheService.optimizeImageUrl(
        imageUrl,
        width: width?.toInt(),
        height: height?.toInt(),
        quality: isCritical ? 90 : 80, // جودة أعلى للصور المهمة
      );
    }
    
    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholderFadeInDuration: placeholderFadeInDuration,
      
      // استخدام مدير الكاش المناسب
      cacheManager: isCritical 
          ? ImageCacheService.criticalCacheManager
          : ImageCacheService.customCacheManager,
      
      // Placeholder أثناء التحميل
      placeholder: (context, url) => placeholder ?? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00c1e8)),
            strokeWidth: 2,
          ),
        ),
      ),
      
      // Error widget في حالة فشل التحميل
      errorWidget: (context, url, error) => errorWidget ?? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Colors.grey[600],
              size: (width != null && width! < 100) ? 20 : 40,
            ),
            if (width == null || width! >= 100) ...[
              const SizedBox(height: 8),
              Text(
                'فشل في تحميل الصورة',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      
      // Cache configuration
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: 800, // تقليل حجم الصور المحفوظة
      maxHeightDiskCache: 800,
    );

    // إضافة BorderRadius إذا طُلب
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

// Widget مخصص للصور الدائرية (للأفاتار)
class CachedCircleImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedCircleImage({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: placeholder ?? Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Colors.grey,
          ),
        ),
        errorWidget: errorWidget ?? Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

// Widget للصور مع تأثير shimmer
class ShimmerCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ShimmerCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey,
              size: 30,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.grey[200],
          ),
          child: const Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 30,
            ),
          ),
        );
      },
      imageBuilder: borderRadius != null
          ? (context, imageProvider) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: fit,
                  ),
                ),
              )
          : null,
    );
  }
}
