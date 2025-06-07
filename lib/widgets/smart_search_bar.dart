// lib/widgets/smart_search_bar.dart

import 'package:flutter/material.dart';
import '../models/store.dart';
import '../screens/enhanced_search_screen.dart';

class SmartSearchBar extends StatefulWidget {
  final List<Store> stores;
  final Set<String> favoriteStoreIds;
  final Function(String) onToggleStoreFavorite;
  final String? hintText;
  final bool autoFocus;

  const SmartSearchBar({
    super.key,
    required this.stores,
    required this.favoriteStoreIds,
    required this.onToggleStoreFavorite,
    this.hintText,
    this.autoFocus = false,
  });

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    // Always open full search when focused
    if (_focusNode.hasFocus) {
      _openFullSearch();
    }
  }

  void _onTextChanged(String query) {
    // Removed inline search functionality - always open full search screen
    _openFullSearch();
  }

  void _openFullSearch() {
    _focusNode.unfocus();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedSearchScreen(
          stores: widget.stores,
          favoriteStoreIds: widget.favoriteStoreIds,
          onToggleStoreFavorite: widget.onToggleStoreFavorite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // إعطاء ارتفاع ثابت
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00c1e8).withOpacity(0.1),
            const Color(0xFF0099d4).withOpacity(0.1),
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
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        onTap: _openFullSearch,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'ابحث في المتاجر، الأطباق، المنتجات...',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF00c1e8),
            size: 24,
          ),
          suffixIcon: IconButton(
            onPressed: _openFullSearch,
            icon: Icon(
              Icons.tune,
              color: const Color(0xFF00c1e8),
            ),
            tooltip: 'بحث متقدم',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12, // تقليل padding العمودي
          ),
        ),
      ),
    );
  }
}
