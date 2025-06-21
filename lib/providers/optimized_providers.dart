// lib/providers/optimized_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/optimized_api_service.dart';
import '../models/store_model.dart';
import '../models/dish_model.dart';

// مزود للمطاعم مع Pagination
final restaurantPaginationProvider = StateNotifierProvider.family<
  RestaurantPaginationNotifier, 
  AsyncValue<List<StoreModel>>,
  RestaurantFilters
>((ref, filters) {
  return RestaurantPaginationNotifier(filters);
});

// مزود للأطباق مع Pagination
final dishPaginationProvider = StateNotifierProvider.family<
  DishPaginationNotifier,
  AsyncValue<List<DishModel>>,
  DishFilters
>((ref, filters) {
  return DishPaginationNotifier(filters);
});

// مزود للبحث السريع
final searchProvider = StateNotifierProvider<
  SearchNotifier,
  AsyncValue<SearchState>
>((ref) {
  return SearchNotifier();
});

// مزود لإحصائيات الأداء
final performanceStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return OptimizedApiService.getPerformanceStats();
});

// Notifier للمطاعم
class RestaurantPaginationNotifier extends StateNotifier<AsyncValue<List<StoreModel>>> {
  final RestaurantFilters filters;
  final List<StoreModel> _allRestaurants = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  RestaurantPaginationNotifier(this.filters) : super(const AsyncValue.loading()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    if (_isLoading) return;
    
    _isLoading = true;
    state = const AsyncValue.loading();
    
    try {
      final response = await OptimizedApiService.getRestaurants(
        page: 1,
        limit: 20,
        search: filters.search,
        category: filters.category,
        filters: filters.additionalFilters,
      );

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final items = data['items'] as List;
        
        _allRestaurants.clear();
        _allRestaurants.addAll(
          items.map((json) => StoreModel.fromJson(json)).toList()
        );
        
        _currentPage = 1;
        _hasMore = items.length == 20;
        state = AsyncValue.data(List.from(_allRestaurants));
      } else {
        state = AsyncValue.error('فشل في تحميل المطاعم', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    
    try {
      final response = await OptimizedApiService.getRestaurants(
        page: _currentPage + 1,
        limit: 20,
        search: filters.search,
        category: filters.category,
        filters: filters.additionalFilters,
      );

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final items = data['items'] as List;
        
        if (items.isNotEmpty) {
          _allRestaurants.addAll(
            items.map((json) => StoreModel.fromJson(json)).toList()
          );
          _currentPage++;
          _hasMore = items.length == 20;
          state = AsyncValue.data(List.from(_allRestaurants));
        } else {
          _hasMore = false;
        }
      }
    } catch (e) {
      // في حالة خطأ في التحميل الإضافي، نبقي البيانات الحالية
      print('خطأ في تحميل المزيد: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    await loadFirstPage();
  }

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  int get totalItems => _allRestaurants.length;
}

// Notifier للأطباق
class DishPaginationNotifier extends StateNotifier<AsyncValue<List<DishModel>>> {
  final DishFilters filters;
  final List<DishModel> _allDishes = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  DishPaginationNotifier(this.filters) : super(const AsyncValue.loading()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    if (_isLoading) return;
    
    _isLoading = true;
    state = const AsyncValue.loading();
    
    try {
      final response = await OptimizedApiService.getDishes(
        page: 1,
        limit: 20,
        storeId: filters.storeId,
        category: filters.category,
        search: filters.search,
        filters: filters.additionalFilters,
      );

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final items = data['items'] as List;
        
        _allDishes.clear();
        _allDishes.addAll(
          items.map((json) => DishModel.fromJson(json)).toList()
        );
        
        _currentPage = 1;
        _hasMore = items.length == 20;
        state = AsyncValue.data(List.from(_allDishes));
      } else {
        state = AsyncValue.error('فشل في تحميل الأطباق', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    
    try {
      final response = await OptimizedApiService.getDishes(
        page: _currentPage + 1,
        limit: 20,
        storeId: filters.storeId,
        category: filters.category,
        search: filters.search,
        filters: filters.additionalFilters,
      );

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final items = data['items'] as List;
        
        if (items.isNotEmpty) {
          _allDishes.addAll(
            items.map((json) => DishModel.fromJson(json)).toList()
          );
          _currentPage++;
          _hasMore = items.length == 20;
          state = AsyncValue.data(List.from(_allDishes));
        } else {
          _hasMore = false;
        }
      }
    } catch (e) {
      print('خطأ في تحميل المزيد: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    await loadFirstPage();
  }

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  int get totalItems => _allDishes.length;
}

// Notifier للبحث
class SearchNotifier extends StateNotifier<AsyncValue<SearchState>> {
  SearchNotifier() : super(const AsyncValue.data(SearchState()));

  Future<void> searchRestaurants(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data(SearchState());
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await OptimizedApiService.smartSearch<StoreModel>(
        query,
        '/api/restaurants/search',
        (json) => StoreModel.fromJson(json),
      );

      state = AsyncValue.data(SearchState(
        restaurants: result.results,
        suggestions: result.suggestions,
        totalResults: result.totalCount,
        searchTime: result.searchTime,
        query: query,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> searchDishes(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data(SearchState());
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await OptimizedApiService.smartSearch<DishModel>(
        query,
        '/api/dishes/search',
        (json) => DishModel.fromJson(json),
      );

      state = AsyncValue.data(SearchState(
        dishes: result.results,
        suggestions: result.suggestions,
        totalResults: result.totalCount,
        searchTime: result.searchTime,
        query: query,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data(SearchState());
  }
}

// نماذج البيانات

class RestaurantFilters {
  final String? search;
  final String? category;
  final Map<String, dynamic>? additionalFilters;

  const RestaurantFilters({
    this.search,
    this.category,
    this.additionalFilters,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantFilters &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          category == other.category;

  @override
  int get hashCode => search.hashCode ^ category.hashCode;
}

class DishFilters {
  final String? storeId;
  final String? category;
  final String? search;
  final Map<String, dynamic>? additionalFilters;

  const DishFilters({
    this.storeId,
    this.category,
    this.search,
    this.additionalFilters,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DishFilters &&
          runtimeType == other.runtimeType &&
          storeId == other.storeId &&
          category == other.category &&
          search == other.search;

  @override
  int get hashCode => storeId.hashCode ^ category.hashCode ^ search.hashCode;
}

class SearchState {
  final List<StoreModel> restaurants;
  final List<DishModel> dishes;
  final List<String> suggestions;
  final int totalResults;
  final int searchTime;
  final String query;

  const SearchState({
    this.restaurants = const [],
    this.dishes = const [],
    this.suggestions = const [],
    this.totalResults = 0,
    this.searchTime = 0,
    this.query = '',
  });

  bool get isEmpty => restaurants.isEmpty && dishes.isEmpty;
  bool get hasResults => restaurants.isNotEmpty || dishes.isNotEmpty;
}

// مزودات إضافية للحالات الشائعة

// مزود المطاعم الشائعة
final popularRestaurantsProvider = FutureProvider<List<StoreModel>>((ref) async {
  final response = await OptimizedApiService.getRestaurants(
    page: 1,
    limit: 10,
    filters: {'sort': 'popular', 'featured': true},
  );

  if (response['status'] == 'success') {
    final data = response['data'] as Map<String, dynamic>;
    final items = data['items'] as List;
    return items.map((json) => StoreModel.fromJson(json)).toList();
  }

  throw Exception('فشل في تحميل المطاعم الشائعة');
});

// مزود الأطباق المميزة
final featuredDishesProvider = FutureProvider<List<DishModel>>((ref) async {
  final response = await OptimizedApiService.getDishes(
    page: 1,
    limit: 10,
    filters: {'featured': true, 'available': true},
  );

  if (response['status'] == 'success') {
    final data = response['data'] as Map<String, dynamic>;
    final items = data['items'] as List;
    return items.map((json) => DishModel.fromJson(json)).toList();
  }

  throw Exception('فشل في تحميل الأطباق المميزة');
});

// مزود تفاصيل المطعم
final restaurantDetailsProvider = FutureProvider.family<StoreModel, String>((ref, restaurantId) async {
  final response = await RestaurantApiExtensions.getRestaurantDetails(restaurantId);

  if (response['status'] == 'success') {
    return StoreModel.fromJson(response['data']);
  }

  throw Exception('فشل في تحميل تفاصيل المطعم');
});

// مزود فئات المطعم
final restaurantCategoriesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, restaurantId) async {
  final response = await RestaurantApiExtensions.getRestaurantCategories(restaurantId);

  if (response['status'] == 'success') {
    return List<Map<String, dynamic>>.from(response['data']);
  }

  throw Exception('فشل في تحميل فئات المطعم');
});

// مزودات الاستفسارات المحسّنة

// مزود البحث السريع للمطاعم
final quickRestaurantSearchProvider = StateProvider<String>((ref) => '');

// مزود البحث السريع للأطباق  
final quickDishSearchProvider = StateProvider<String>((ref) => '');

// مزود الفلاتر النشطة
final activeFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// مزود حالة التحميل العامة
final globalLoadingProvider = StateProvider<bool>((ref) => false);

// مزود الأخطاء العامة
final globalErrorProvider = StateProvider<String?>((ref) => null);
