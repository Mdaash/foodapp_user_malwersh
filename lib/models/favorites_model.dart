// lib/models/favorites_model.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// نموذج إدارة المفضلة مع التزامن في الوقت الفعلي
class FavoritesModel extends ChangeNotifier {
  // مجموعات المفضلة
  final Set<String> _favoriteStoreIds = {};
  final Set<String> _favoriteDishIds = {};
  final Set<String> _favoriteOfferIds = {};

  // الحصول على المفضلة (قراءة فقط)
  Set<String> get favoriteStoreIds => Set.unmodifiable(_favoriteStoreIds);
  Set<String> get favoriteDishIds => Set.unmodifiable(_favoriteDishIds);
  Set<String> get favoriteOfferIds => Set.unmodifiable(_favoriteOfferIds);

  // التحقق من حالة المفضلة
  bool isStoreFavorite(String storeId) => _favoriteStoreIds.contains(storeId);
  bool isDishFavorite(String dishId) => _favoriteDishIds.contains(dishId);
  bool isOfferFavorite(String offerId) => _favoriteOfferIds.contains(offerId);

  // إجمالي عدد المفضلة
  int get totalFavoritesCount => 
      _favoriteStoreIds.length + _favoriteDishIds.length + _favoriteOfferIds.length;

  // تبديل حالة المتجر المفضل
  void toggleStoreFavorite(String storeId) {
    if (_favoriteStoreIds.contains(storeId)) {
      _favoriteStoreIds.remove(storeId);
    } else {
      _favoriteStoreIds.add(storeId);
    }
    notifyListeners();
    _saveFavorites(); // حفظ تلقائي
  }

  // تبديل حالة الطبق المفضل
  void toggleDishFavorite(String dishId) {
    if (_favoriteDishIds.contains(dishId)) {
      _favoriteDishIds.remove(dishId);
    } else {
      _favoriteDishIds.add(dishId);
    }
    notifyListeners();
    _saveFavorites(); // حفظ تلقائي
  }

  // تبديل حالة العرض المفضل
  void toggleOfferFavorite(String offerId) {
    if (_favoriteOfferIds.contains(offerId)) {
      _favoriteOfferIds.remove(offerId);
    } else {
      _favoriteOfferIds.add(offerId);
    }
    notifyListeners();
    _saveFavorites(); // حفظ تلقائي
  }

  // إضافة متجر للمفضلة
  void addStoreFavorite(String storeId) {
    if (!_favoriteStoreIds.contains(storeId)) {
      _favoriteStoreIds.add(storeId);
      notifyListeners();
      _saveFavorites();
    }
  }

  // إزالة متجر من المفضلة
  void removeStoreFavorite(String storeId) {
    if (_favoriteStoreIds.contains(storeId)) {
      _favoriteStoreIds.remove(storeId);
      notifyListeners();
      _saveFavorites();
    }
  }

  // إضافة طبق للمفضلة
  void addDishFavorite(String dishId) {
    if (!_favoriteDishIds.contains(dishId)) {
      _favoriteDishIds.add(dishId);
      notifyListeners();
      _saveFavorites();
    }
  }

  // إزالة طبق من المفضلة
  void removeDishFavorite(String dishId) {
    if (_favoriteDishIds.contains(dishId)) {
      _favoriteDishIds.remove(dishId);
      notifyListeners();
      _saveFavorites();
    }
  }

  // إضافة عرض للمفضلة
  void addOfferFavorite(String offerId) {
    if (!_favoriteOfferIds.contains(offerId)) {
      _favoriteOfferIds.add(offerId);
      notifyListeners();
      _saveFavorites();
    }
  }

  // إزالة عرض من المفضلة
  void removeOfferFavorite(String offerId) {
    if (_favoriteOfferIds.contains(offerId)) {
      _favoriteOfferIds.remove(offerId);
      notifyListeners();
      _saveFavorites();
    }
  }

  // مسح جميع المفضلة
  void clearAllFavorites() {
    _favoriteStoreIds.clear();
    _favoriteDishIds.clear();
    _favoriteOfferIds.clear();
    notifyListeners();
    _saveFavorites();
  }

  // مسح مفضلة المتاجر فقط
  void clearStoreFavorites() {
    _favoriteStoreIds.clear();
    notifyListeners();
    _saveFavorites();
  }

  // مسح مفضلة الأطباق فقط
  void clearDishFavorites() {
    _favoriteDishIds.clear();
    notifyListeners();
    _saveFavorites();
  }

  // مسح مفضلة العروض فقط
  void clearOfferFavorites() {
    _favoriteOfferIds.clear();
    notifyListeners();
    _saveFavorites();
  }

  // حفظ المفضلة محلياً
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // حفظ كـ JSON لسهولة القراءة والكتابة
      final favoritesData = {
        'stores': _favoriteStoreIds.toList(),
        'dishes': _favoriteDishIds.toList(),
        'offers': _favoriteOfferIds.toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString('favorites_data', jsonEncode(favoritesData));
    } catch (e) {
      debugPrint('خطأ في حفظ المفضلة: $e');
    }
  }

  // تحميل المفضلة المحفوظة
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites_data');
      
      if (favoritesJson != null) {
        final favoritesData = jsonDecode(favoritesJson) as Map<String, dynamic>;
        
        // تحميل المتاجر المفضلة
        final stores = favoritesData['stores'] as List<dynamic>?;
        if (stores != null) {
          _favoriteStoreIds.clear();
          _favoriteStoreIds.addAll(stores.cast<String>());
        }
        
        // تحميل الأطباق المفضلة
        final dishes = favoritesData['dishes'] as List<dynamic>?;
        if (dishes != null) {
          _favoriteDishIds.clear();
          _favoriteDishIds.addAll(dishes.cast<String>());
        }
        
        // تحميل العروض المفضلة
        final offers = favoritesData['offers'] as List<dynamic>?;
        if (offers != null) {
          _favoriteOfferIds.clear();
          _favoriteOfferIds.addAll(offers.cast<String>());
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المفضلة: $e');
    }
  }

  // استيراد مفضلة من مصدر خارجي (مثل السحابة)
  void importFavorites({
    List<String>? storeIds,
    List<String>? dishIds,
    List<String>? offerIds,
  }) {
    if (storeIds != null) {
      _favoriteStoreIds.clear();
      _favoriteStoreIds.addAll(storeIds);
    }
    
    if (dishIds != null) {
      _favoriteDishIds.clear();
      _favoriteDishIds.addAll(dishIds);
    }
    
    if (offerIds != null) {
      _favoriteOfferIds.clear();
      _favoriteOfferIds.addAll(offerIds);
    }
    
    notifyListeners();
    _saveFavorites();
  }

  // تصدير المفضلة (للنسخ الاحتياطي أو المزامنة)
  Map<String, List<String>> exportFavorites() {
    return {
      'stores': _favoriteStoreIds.toList(),
      'dishes': _favoriteDishIds.toList(),
      'offers': _favoriteOfferIds.toList(),
    };
  }

  // إحصائيات المفضلة
  Map<String, int> getFavoritesStats() {
    return {
      'storesCount': _favoriteStoreIds.length,
      'dishesCount': _favoriteDishIds.length,
      'offersCount': _favoriteOfferIds.length,
      'totalCount': totalFavoritesCount,
    };
  }
}
