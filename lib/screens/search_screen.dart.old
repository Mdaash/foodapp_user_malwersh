import 'package:flutter/material.dart';
import '../models/store.dart';
import '../services/search_service.dart';
import '../models/search_result.dart';
import 'store_detail_screen.dart';
import 'dish_detail_screen.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  final List<Store> stores;
  final Set<String> favoriteStoreIds;
  final Function(String) onToggleStoreFavorite;

  const SearchScreen({
    super.key,
    required this.stores,
    required this.favoriteStoreIds,
    required this.onToggleStoreFavorite,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _debounceTimer;

  // قائمة الكلمات الشائعة للبحث السريع
  List<String> _popularSearches = [
    'برجر',
    'بيتزا',
    'دجاج مقلي',
    'سوشي',
    'شاورما',
    'مشروبات',
    'حلويات',
    'مأكولات بحرية',
    'إفطار',
    'قهوة',
  ];

  // قائمة البحث الحديث
  final List<String> _recentSearches = [];

  // فلاتر البحث
  List<SearchResultType> _selectedTypes = SearchResultType.values;
  
  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _loadPopularSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // تحميل البحث الشائع من الباك إند
  Future<void> _loadPopularSearches() async {
    try {
      final popularSearches = await searchService.getPopularSearches();
      if (mounted) {
        setState(() {
          _popularSearches = popularSearches;
        });
      }
    } catch (e) {
      print('خطأ في تحميل البحث الشائع: $e');
    }
  }

  // البحث مع debouncing وتحسينات الأداء
  void _performSearch(String query) {
    // إلغاء البحث السابق
    _debounceTimer?.cancel();
    
    setState(() {
      _isSearching = query.isNotEmpty;
      
      if (query.isEmpty) {
        _searchResults = [];
        return;
      }
    });

    // البحث المحلي الفوري (للتجربة السلسة)
    _performLocalSearch(query);
    
    // البحث المتقدم مع debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _performAdvancedSearch(query);
    });
  }

  // البحث المحلي الفوري
  void _performLocalSearch(String query) {
    // إضافة البحث إلى القائمة الحديثة
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }

    // البحث الشامل باستخدام searchUniversal
    searchService.searchUniversal(
      query,
      localStores: widget.stores,
      searchTypes: _selectedTypes,
      limit: 20,
    ).then((results) {
      if (mounted && _searchController.text == query) {
        setState(() {
          _searchResults = results;
        });
      }
    });
  }

  // البحث المتقدم من الباك إند
  Future<void> _performAdvancedSearch(String query) async {
    try {
      // البحث الشامل من الباك إند مع معلومات إضافية
      final backendResults = await searchService.searchUniversal(
        query,
        localStores: widget.stores,
        searchTypes: _selectedTypes,
        // يمكن إضافة المزيد من المعاملات حسب الحاجة
        // category: selectedCategory,
        // latitude: currentLatitude,
        // longitude: currentLongitude,
      );

      if (mounted) {
        setState(() {
          // دمج النتائج وإزالة المكررات
          final combinedResults = <SearchResult>[];
          final seenIds = <String>{};
          
          // إضافة النتائج المحلية أولاً
          for (final result in _searchResults) {
            if (!seenIds.contains(result.id)) {
              combinedResults.add(result);
              seenIds.add(result.id);
            }
          }
          
          // إضافة النتائج الجديدة من الباك إند
          for (final result in backendResults) {
            if (!seenIds.contains(result.id)) {
              combinedResults.add(result);
              seenIds.add(result.id);
            }
          }
          
          _searchResults = combinedResults;
        });

        // تسجيل إحصائيات البحث
        searchService.logSearchEvent(query, _searchResults.length);
      }
    } catch (e) {
      print('خطأ في البحث المتقدم: $e');
    }
  }

  void _onSearchTermSelected(String term) {
    _searchController.text = term;
    _performSearch(term);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildSearchHeader(),
                _buildSearchFilters(),
                Expanded(
                  child: _isSearching 
                      ? _buildSearchResults() 
                      : _buildSearchSuggestions(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00c1e8).withOpacity(0.1),
                    const Color(0xFF00c1e8).withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFF00c1e8).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _performSearch,
                textInputAction: TextInputAction.search,
                onSubmitted: _performSearch,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث في المتاجر، الأطباق، المنتجات والعروض...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF00c1e8),
                    size: 24,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // فلاتر البحث الجديدة
  Widget _buildSearchFilters() {
    if (!_isSearching) return const SizedBox.shrink();
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: SearchResultType.values.length,
        itemBuilder: (context, index) {
          final type = SearchResultType.values[index];
          final isSelected = _selectedTypes.contains(type);
          
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(type),
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF00c1e8),
                  ),
                  const SizedBox(width: 6),
                  Text(_getTypeDisplayName(type)),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add(type);
                  } else {
                    _selectedTypes.remove(type);
                  }
                });
                // إعادة البحث مع الفلاتر الجديدة
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
              selectedColor: const Color(0xFF00c1e8),
              backgroundColor: const Color(0xFF00c1e8).withOpacity(0.1),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF00c1e8),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildEmptyResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    final isFavorite = widget.favoriteStoreIds.contains(result.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(                  image: AssetImage(result.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          result.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.subtitle,
              style: TextStyle(
                color: const Color(0xFF00c1e8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber[600],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  result.type == SearchResultType.store && result.store != null 
                      ? result.store!.rating.toString()
                      : '4.5',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  result.type == SearchResultType.store && result.store != null 
                      ? result.store!.time
                      : '30 دقيقة',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => widget.onToggleStoreFavorite(result.id),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
        ),
        onTap: () {
          // الانتقال إلى تفاصيل المتجر أو الطبق حسب نوع النتيجة
          if (result.type == SearchResultType.store && result.store != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreDetailScreen(
                  store: result.store!,
                  favoriteStoreIds: widget.favoriteStoreIds,
                  onFavoriteToggle: (isFavorite) {
                    widget.onToggleStoreFavorite(result.store!.id);
                  },
                ),
              ),
            );
          } else if (result.type == SearchResultType.dish && result.dish != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DishDetailScreen(
                  dish: result.dish!,
                  storeId: result.storeId!,
                  isInitiallyFav: false,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00c1e8).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: const Color(0xFF00c1e8).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لم يتم العثور على نتائج',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // البحث الحديث
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader('البحث الحديث', Icons.history),
            const SizedBox(height: 12),
            ..._recentSearches.map((search) => _buildSearchItem(
              search,
              Icons.history,
              () => _onSearchTermSelected(search),
            )),
            const SizedBox(height: 24),
          ],
          
          // البحث الشائع
          _buildSectionHeader('البحث الشائع', Icons.trending_up),
          const SizedBox(height: 12),
          ..._popularSearches.map((search) => _buildSearchItem(
            search,
            Icons.trending_up,
            () => _onSearchTermSelected(search),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00c1e8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00c1e8),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchItem(String text, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.north_west,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  IconData _getTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.store:
        return Icons.store;
      case SearchResultType.dish:
        return Icons.restaurant_menu;
      case SearchResultType.offer:
        return Icons.local_offer;
      case SearchResultType.product:
        return Icons.shopping_cart;
      default:
        return Icons.search;
    }
  }

  String _getTypeDisplayName(SearchResultType type) {
    switch (type) {
      case SearchResultType.store:
        return 'المتاجر';
      case SearchResultType.dish:
        return 'الأطباق';
      case SearchResultType.offer:
        return 'العروض';
      case SearchResultType.product:
        return 'المنتجات';
      default:
        return 'الكل';
    }
  }
}
