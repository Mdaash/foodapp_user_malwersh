// lib/widgets/modern_cart_icon.dart

import 'package:flutter/material.dart';
import 'dart:ui';

class ModernCartIcon extends StatelessWidget {
  final Color color;
  final double size;
  final bool hasGlowEffect;
  final VoidCallback? onPressed;
  final int? badgeCount;
  final bool isGlassmorphic;

  const ModernCartIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
    this.hasGlowEffect = false,
    this.onPressed,
    this.badgeCount,
    this.isGlassmorphic = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isGlassmorphic ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
        ) : null,
        color: isGlassmorphic ? null : color.withValues(alpha: 0.1),
        border: isGlassmorphic ? Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ) : null,
        boxShadow: hasGlowEffect ? [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ] : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: isGlassmorphic ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: isGlassmorphic ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ) : null,
            ),
            child: Center(                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isGlassmorphic ? [
                        color,
                        color.withValues(alpha: 0.8),
                      ] : [color, color],
                    ).createShader(bounds);
                  },
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: size,
                    color: Colors.white,
                  ),
                ),
            ),
          ),
        ),
      ),
    );

    // إضافة Badge إذا كان مطلوب
    if (badgeCount != null && badgeCount! > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDF1067), Color(0xFFFF6B6B)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDF1067).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                badgeCount! > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // إضافة GestureDetector إذا كان مطلوب
    if (onPressed != null) {
      return GestureDetector(
        onTap: onPressed,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}

// Widget للأيقونة الدائرية بتصميم زجاجي
class ModernCartCircleIcon extends StatelessWidget {
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final VoidCallback? onPressed;
  final int? badgeCount;

  const ModernCartCircleIcon({
    super.key,
    this.backgroundColor = const Color(0xFF00c1e8),
    this.iconColor = Colors.white,
    this.size = 56,
    this.onPressed,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      iconColor,
                      iconColor.withValues(alpha: 0.9),
                    ],
                  ).createShader(bounds);
                },
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: size * 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // إضافة Badge إذا كان مطلوب
    if (badgeCount != null && badgeCount! > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: size * 0.05,
            top: size * 0.05,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDF1067), Color(0xFFFF6B6B)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDF1067).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                badgeCount! > 99 ? '99+' : '$badgeCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // إضافة GestureDetector إذا كان مطلوب
    if (onPressed != null) {
      return GestureDetector(
        onTap: onPressed,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
