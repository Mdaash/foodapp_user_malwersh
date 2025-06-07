// lib/widgets/animated_cart_bar.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../screens/cart_screen.dart';
import 'modern_cart_icon.dart';

class AnimatedCartBar extends StatefulWidget {
  final String storeName;
  final bool isExpanded;

  const AnimatedCartBar({
    super.key,
    required this.storeName,
    required this.isExpanded,
  });

  @override
  State<AnimatedCartBar> createState() => _AnimatedCartBarState();
}

class _AnimatedCartBarState extends State<AnimatedCartBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtl;
  late final Animation<double> _scaleAnim;
  late int _prevCount;
  Timer? _timer;
  CartModel? _cartModel; // إضافة مرجع للـ CartModel

  static const Color _primaryPink = Color(0xFF00c1e8);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // حفظ مرجع للـ CartModel هنا بدلاً من في dispose()
    _cartModel = context.read<CartModel>();
  }

  @override
  void initState() {
    super.initState();

    _pulseCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulseCtl, curve: Curves.easeInOut));

    final cart = context.read<CartModel>();
    _prevCount = cart.items.length;

    if (widget.isExpanded) {
      // نبضة عند إضافة عنصر جديد فقط
      cart.addListener(_onCartChanged);
    } else {
      // نبضة كل 5 ثوانٍ
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        _pulseCtl.forward(from: 0);
      });
    }
  }

  void _onCartChanged() {
    // Debug: AnimatedCartBar: _onCartChanged called
    final cart = _cartModel ?? context.read<CartModel>();
    if (cart.items.length != _prevCount) {
      _prevCount = cart.items.length;
      _pulseCtl.forward(from: 0);
      // Debug: AnimatedCartBar: Pulse animation triggered
    }
  }

  @override
  void dispose() {
    if (widget.isExpanded && _cartModel != null) {
      _cartModel!.removeListener(_onCartChanged);
    }
    _timer?.cancel();
    _pulseCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug: AnimatedCartBar build: isExpanded = ${widget.isExpanded}
    final cart = context.watch<CartModel>();
    if (cart.items.isEmpty) return const SizedBox.shrink();

    final alignment = widget.isExpanded
        ? Alignment.bottomCenter
        : Alignment.bottomLeft;
    final padding = widget.isExpanded
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
        : const EdgeInsets.only(left: 24, bottom: 12);

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: GestureDetector(
            onTap: () {
              // Debug: AnimatedCartBar tapped! Navigating to CartScreen...
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartScreen(storeName: widget.storeName),
                ),
              );
            },
            child: widget.isExpanded
                ? _buildExpanded(cart.items.length)
                : _buildCollapsed(cart.items.length),
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded(int count) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _primaryPink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ModernCartIcon(
              color: Colors.white,
              size: 28,
              hasGlowEffect: true,
              isGlassmorphic: false,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'عرض السلة',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              Text(
                widget.storeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: _primaryPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsed(int count) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _primaryPink,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ModernCartCircleIcon(
            backgroundColor: _primaryPink,
            iconColor: Colors.white,
            size: 56,
            badgeCount: count,
          ),
        ],
      ),
    );
  }
}
