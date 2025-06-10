// lib/widgets/smart_search_bar_updated.dart

import 'package:flutter/material.dart';
import '../models/store.dart';
import '../screens/enhanced_search_screen.dart';

class SmartSearchBarUpdated extends StatefulWidget {
  final List<Store> stores;
  final String? hintText;
  final bool autoFocus;

  const SmartSearchBarUpdated({
    super.key,
    required this.stores,
    this.hintText,
    this.autoFocus = false,
  });

  @override
  State<SmartSearchBarUpdated> createState() => _SmartSearchBarUpdatedState();
}

class _SmartSearchBarUpdatedState extends State<SmartSearchBarUpdated> {
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
    // This triggers search, but since we navigate to full screen immediately,
    // this might be less relevant now
  }

  void _openFullSearch() {
    // Unfocus to prevent keyboard issues
    _focusNode.unfocus();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedSearchScreen(
          stores: widget.stores,
          initialQuery: _controller.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onTextChanged,
                autofocus: widget.autoFocus,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'ابحث عن متجر أو طبق...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[600], size: 18),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
