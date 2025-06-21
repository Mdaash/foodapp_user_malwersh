// lib/widgets/optimized_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ويدجت محسّن لعرض البيانات بدون StatefulWidget
class OptimizedDataBuilder<T> extends ConsumerWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final bool Function(T data)? isEmpty;

  const OptimizedDataBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? 
            const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error!) ?? 
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('خطأ: ${snapshot.error}'),
                ],
              ),
            );
        }

        if (!snapshot.hasData) {
          return emptyBuilder?.call(context) ?? 
            const Center(child: Text('لا توجد بيانات'));
        }

        final data = snapshot.data as T;
        
        // فحص إذا كانت البيانات فارغة
        if (isEmpty?.call(data) == true) {
          return emptyBuilder?.call(context) ?? 
            const Center(child: Text('لا توجد بيانات لعرضها'));
        }

        return builder(context, data);
      },
    );
  }
}

// ويدجت محسّن للقوائم اللانهائية
class OptimizedInfiniteList<T> extends ConsumerWidget {
  final Future<List<T>> Function(int page) loadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final int itemsPerPage;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedInfiniteList({
    super.key,
    required this.loadMore,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.itemsPerPage = 20,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _InfiniteListState<T>(
      loadMore: loadMore,
      itemBuilder: itemBuilder,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      emptyWidget: emptyWidget,
      itemsPerPage: itemsPerPage,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
    );
  }
}

// حالة للقائمة اللانهائية
class _InfiniteListState<T> extends StatefulWidget {
  final Future<List<T>> Function(int page) loadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final int itemsPerPage;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const _InfiniteListState({
    super.key,
    required this.loadMore,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.itemsPerPage = 20,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<_InfiniteListState<T>> createState() => _InfiniteListStateImpl<T>();
}

class _InfiniteListStateImpl<T> extends State<_InfiniteListState<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newItems = await widget.loadMore(1);
      setState(() {
        _items.clear();
        _items.addAll(newItems);
        _currentPage = 1;
        _hasMore = newItems.length == widget.itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await widget.loadMore(_currentPage + 1);
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length == widget.itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return widget.errorWidget ?? 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('خطأ: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFirstPage,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
    }

    if (_items.isEmpty && _isLoading) {
      return widget.loadingWidget ?? 
        const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return widget.emptyWidget ?? 
        const Center(child: Text('لا توجد عناصر لعرضها'));
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: widget.padding,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return widget.itemBuilder(context, _items[index], index);
        },
      ),
    );
  }
}

// ويدجت محسّن للنماذج
class OptimizedForm extends ConsumerWidget {
  final List<OptimizedFormField> fields;
  final void Function(Map<String, dynamic> data) onSubmit;
  final Widget? submitButton;
  final EdgeInsetsGeometry? padding;
  final bool validateOnChange;

  const OptimizedForm({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.submitButton,
    this.padding,
    this.validateOnChange = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final formData = <String, dynamic>{};

    return Form(
      key: formKey,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          children: [
            ...fields.map((field) => _buildFormField(field, formData)),
            const SizedBox(height: 24),
            submitButton ?? 
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    onSubmit(formData);
                  }
                },
                child: const Text('إرسال'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(OptimizedFormField field, Map<String, dynamic> formData) {
    switch (field.type) {
      case FormFieldType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint,
              border: const OutlineInputBorder(),
            ),
            validator: field.validator,
            onSaved: (value) => formData[field.key] = value,
            obscureText: field.isPassword,
            keyboardType: field.keyboardType,
          ),
        );

      case FormFieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            items: field.options?.map((option) => 
              DropdownMenuItem(
                value: option['value'],
                child: Text(option['label'] ?? ''),
              ),
            ).toList(),
            validator: field.validator,
            onSaved: (value) => formData[field.key] = value,
            onChanged: (value) {
              // Handle value change
            },
          ),
        );

      case FormFieldType.checkbox:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CheckboxListTile(
            title: Text(field.label),
            onChanged: (value) => formData[field.key] = value,
            value: formData[field.key] ?? false,
          ),
        );
    }
  }
}

// نموذج حقل النموذج
class OptimizedFormField {
  final String key;
  final String label;
  final String? hint;
  final FormFieldType type;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType? keyboardType;
  final List<Map<String, String>>? options;

  OptimizedFormField({
    required this.key,
    required this.label,
    this.hint,
    this.type = FormFieldType.text,
    this.validator,
    this.isPassword = false,
    this.keyboardType,
    this.options,
  });
}

enum FormFieldType {
  text,
  dropdown,
  checkbox,
}

// ويدجت محسّن للصور مع كاش
class OptimizedImage extends ConsumerWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableHeroAnimation;
  final String? heroTag;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableHeroAnimation = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder ?? 
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? 
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
            ),
          );
      },
    );

    if (enableHeroAnimation && heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

// ويدجت محسّن لعرض الحالة
class OptimizedStateWidget<T> extends ConsumerWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error, StackTrace stackTrace)? errorBuilder;

  const OptimizedStateWidget({
    super.key,
    required this.asyncValue,
    required this.dataBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncValue.when(
      data: (data) => dataBuilder(context, data),
      loading: () => loadingBuilder?.call(context) ?? 
        const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => errorBuilder?.call(context, error, stackTrace) ?? 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('خطأ: $error'),
            ],
          ),
        ),
    );
  }
}

// ويدجت محسّن للبحث
class OptimizedSearchBar extends ConsumerWidget {
  final String? hintText;
  final void Function(String query) onSearch;
  final void Function()? onClear;
  final Duration debounceTime;
  final EdgeInsetsGeometry? margin;

  const OptimizedSearchBar({
    super.key,
    this.hintText,
    required this.onSearch,
    this.onClear,
    this.debounceTime = const Duration(milliseconds: 500),
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[100],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText ?? 'بحث...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: onClear,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
        onChanged: (value) {
          // تطبيق debounce للبحث
          Future.delayed(debounceTime, () {
            onSearch(value);
          });
        },
      ),
    );
  }
}
