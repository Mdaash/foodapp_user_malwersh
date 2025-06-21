// lib/config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class Config {
  /// عنوان الخادم الحقيقي - يرجى تحديث هذا العنوان بعنوان الخادم الحقيقي
  static String get apiBaseUrl {
    // استخدم عنوان الخادم الحقيقي بدلاً من localhost
    // قم بتحديث هذا العنوان بعنوان الخادم الخاص بك
    const String realServerUrl = 'http://127.0.0.1:8080';
    
    // إذا كنت تريد استخدام localhost للاختبار، غير الثابت أدناه إلى true
    const bool useLocalhost = false;
    
    if (useLocalhost) {
      if (kIsWeb) {
        // للويب - استخدم localhost
        return 'http://127.0.0.1:8080';
      } else if (Platform.isAndroid) {
        // للمحاكي Android - استخدم 10.0.2.2 للاتصال بالجهاز المضيف
        return 'http://10.0.2.2:8080';
      } else if (Platform.isIOS) {
        // لمحاكي iOS - استخدم localhost
        return 'http://127.0.0.1:8080';
      } else {
        // للمنصات الأخرى - استخدم localhost
        return 'http://127.0.0.1:8080';
      }
    } else {
      // استخدم الخادم الحقيقي
      return realServerUrl;
    }
  }
}
