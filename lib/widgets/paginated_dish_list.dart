// lib/widgets/paginated_dish_list.dart
import 'package:flutter/material.dart';
import 'package:foodapp_user/services/api_service.dart';
import '../services/pagination_service.dart';
import '../models/dish_model.dart';
import 'dish_card.dart';

class PaginatedDishList extends StatefulWidget {
  final String? storeId;
  final String? category;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PaginatedDishList({
    super.key,
    this.storeId,
    this.category,
    this.searchQuery,
    this.filters,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<PaginatedDishList> createState() => _PaginatedDishListState();
}

class _PaginatedDishListState extends State<PaginatedDishList> {
  late PaginationService<DishModel> _paginationService;
  
  @override
  void initState() {
    super.initState();
    _initializePaginationService();
  }

  void _initializePaginationService() {
    _paginationService = PaginationService<DishModel>(
      fetchData: (page, limit) => _fetchDishes(page, limit),
      itemsPerPage: 20,
    );
  }

  Future<List<DishModel>> _fetchDishes(int page, int limit) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // إضافة فلاتر البحث
      if (widget.storeId?.isNotEmpty == true) {
        queryParams['store_id'] = widget.storeId;
      }
      
      if (widget.category?.isNotEmpty == true) {
        queryParams['category'] = widget.category;
      }

      if (widget.searchQuery?.isNotEmpty == true) {
        queryParams['search'] = widget.searchQuery;
      }

      // إضافة فلاتر إضافية
      if (widget.filters != null) {
        queryParams.addAll(widget.filters!);
      }

      final response = await ApiService.fetch('/api/dishes', queryParams: queryParams);
      
      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final items = data['items'] as List;
        
        return items.map((json) => DishModel.fromJson(json)).toList();
      }
      
      throw Exception('فشل في تحميل الأطباق');
    } catch (e) {
      throw Exception('خطأ في الشبكة: $e');
    }
  }

  @override
  void didUpdateWidget(PaginatedDishList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // إذا تغيرت المعاملات، أعد تحميل البيانات
    if (oldWidget.storeId != widget.storeId ||
        oldWidget.category != widget.category ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filters != widget.filters) {
      _paginationService.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedListWidget<DishModel>(
      paginationService: _paginationService,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      
      itemBuilder: (context, dish, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DishCard(
            dish: dish,
            onTap: () {
              _navigateToDishDetail(dish);
            },
            onAddToCart: () {
              _addToCart(dish);
            },
            isCompact: false,
          ),
        );
      },
      
      loadingWidget: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      
      errorWidget: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_menu_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'خطأ في تحميل الأطباق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تحقق من اتصال الإنترنت وحاول مرة أخرى',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _paginationService.refresh(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
      
      emptyWidget: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.no_meals_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'لا توجد أطباق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.searchQuery?.isNotEmpty == true
                    ? 'لم نجد أطباق تطابق "${widget.searchQuery}"'
                    : 'لا توجد أطباق متاحة حالياً',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDishDetail(DishModel dish) {
    Navigator.pushNamed(
      context,
      '/dish_detail',
      arguments: dish,
    );
  }

  void _addToCart(DishModel dish) {
    // إضافة للسلة - سيتم ربطه مع CartProvider
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${dish.name} للسلة'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _paginationService.dispose();
    super.dispose();
  }
}

// ويدجت شبكة للأطباق
class PaginatedDishGrid extends StatefulWidget {
  final String? storeId;
  final String? category;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const PaginatedDishGrid({
    super.key,
    this.storeId,
    this.category,
    this.searchQuery,
    this.filters,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.padding,
  });

  @override
  State<PaginatedDishGrid> createState() => _PaginatedDishGridState();
}

class _PaginatedDishGridState extends State<PaginatedDishGrid> {
  late PaginationService<DishModel> _paginationService;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    _paginationService = PaginationService<DishModel>(
      fetchData: (page, limit) => _fetchDishes(page, limit),
      itemsPerPage: 20,
    );
  }

  Future<List<DishModel>> _fetchDishes(int page, int limit) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (widget.storeId?.isNotEmpty == true) {
      queryParams['store_id'] = widget.storeId;
    }
    
    if (widget.category?.isNotEmpty == true) {
      queryParams['category'] = widget.category;
    }

    if (widget.searchQuery?.isNotEmpty == true) {
      queryParams['search'] = widget.searchQuery;
    }

    if (widget.filters != null) {
      queryParams.addAll(widget.filters!);
    }

    final response = await ApiService.fetch('/api/dishes', queryParams: queryParams);
    
    if (response['status'] == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      final items = data['items'] as List;
      
      return items.map((json) => DishModel.fromJson(json)).toList();
    }
    
    throw Exception('فشل في تحميل الأطباق');
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _paginationService.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBuilder<PaginationService<DishModel>>(
      notifier: _paginationService,
      builder: (context, service) {
        if (service.error != null && service.items.isEmpty) {
          return const Center(
            child: Text('خطأ في تحميل الأطباق'),
          );
        }

        if (service.items.isEmpty && service.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => service.refresh(),
          child: GridView.builder(
            controller: _scrollController,
            padding: widget.padding ?? const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              childAspectRatio: widget.childAspectRatio,
              crossAxisSpacing: widget.crossAxisSpacing,
              mainAxisSpacing: widget.mainAxisSpacing,
            ),
            itemCount: service.items.length + (service.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= service.items.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final dish = service.items[index];
              return DishCard(
                dish: dish,
                isCompact: true,
                onTap: () => _navigateToDishDetail(dish),
                onAddToCart: () => _addToCart(dish),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToDishDetail(DishModel dish) {
    Navigator.pushNamed(
      context,
      '/dish_detail',
      arguments: dish,
    );
  }

  void _addToCart(DishModel dish) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${dish.name} للسلة'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void didUpdateWidget(PaginatedDishGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.storeId != widget.storeId ||
        oldWidget.category != widget.category ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filters != widget.filters) {
      _paginationService.refresh();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _paginationService.dispose();
    super.dispose();
  }
}

// ويدجت للأطباق حسب الفئة مع Pagination
class CategoryDishList extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? storeId;

  const CategoryDishList({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.storeId,
  });

  @override
  State<CategoryDishList> createState() => _CategoryDishListState();
}

class _CategoryDishListState extends State<CategoryDishList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان الفئة
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                widget.categoryName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showAllDishes(),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        
        // قائمة الأطباق
        SizedBox(
          height: 280,
          child: PaginatedDishList(
            storeId: widget.storeId,
            category: widget.categoryId,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
        ),
      ],
    );
  }

  void _showAllDishes() {
    Navigator.pushNamed(
      context,
      '/category_dishes',
      arguments: {
        'categoryId': widget.categoryId,
        'categoryName': widget.categoryName,
        'storeId': widget.storeId,
      },
    );
  }
}
