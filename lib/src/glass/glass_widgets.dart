//flutter_paystack_plus/lib/src/glass/glass_widgets.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'decorations.dart';
import 'int_extensions.dart';
import 'dynamic_theme.dart';

/// 📦 GLASS CARD
/// Standard card with glassmorphic effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final GlassIntensity intensity;
  final Color? tintColor;

  const GlassCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.intensity = GlassIntensity.medium,
    this.tintColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? radius(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _getBlurForIntensity(),
            sigmaY: _getBlurForIntensity(),
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: boxDecorationGlass(
              context,
              intensity: intensity,
              tintColor: tintColor,
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? radius(16),
          child: content,
        ),
      );
    }

    return content;
  }

  double _getBlurForIntensity() {
    switch (intensity) {
      case GlassIntensity.subtle:
        return 6.0;
      case GlassIntensity.medium:
        return 10.0;
      case GlassIntensity.strong:
        return 15.0;
    }
  }
}

/// 🍎 APPLE GLASS CARD
/// iOS-style glassmorphic card with brand color tint
class AppleGlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? tintColor;

  const AppleGlassCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.tintColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? radius(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: boxDecorationAppleGlass(
              context,
              tintColor: tintColor,
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? radius(16),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// 🎨 GLASS APP BAR
/// Glassmorphic app bar with blur effect
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final double? elevation;
  final Color? tintColor;
  final double height;

  const GlassAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.elevation,
    this.tintColor,
    this.height = 56.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height + MediaQuery.of(context).padding.top,
          decoration: boxDecorationGlass(
            context,
            intensity: GlassIntensity.medium,
            tintColor: tintColor,
            borderRadius: BorderRadius.zero,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  if (leading != null) leading!,
                  if (leading == null && Navigator.canPop(context))
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: titleWidget ??
                        Text(
                          title ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

/// 🔘 GLASS BUTTON - IMPROVED
/// Glassmorphic button with BOLD, HIGH-CONTRAST background
/// Fixed: No more washed out appearance!
///
/// Usage:
/// ```dart
/// GlassButton(
///   text: 'Click Me',
///   tintColor: Colors.blue, // Still works!
///   onPressed: () => developer.log('pressed'),
/// )
/// ```
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? tintColor; // KEPT for backward compatibility
  final BorderRadius? borderRadius;
  final GlassButtonStyle style; // NEW: Choose button style

  const GlassButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.tintColor, // Keep existing API
    this.borderRadius,
    this.style = GlassButtonStyle.solid, // Default to solid for best contrast
  }) : super(key: key);

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

/// NEW: Button style options
enum GlassButtonStyle {
  solid, // Bold solid color with subtle glass effect (best contrast)
  glassy, // More transparent with stronger blur
  outlined, // Transparent with colored border
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.tintColor ?? ColorUtils.colorPrimary; // Use tintColor
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: SizedBox(
            width: widget.width,
            height: widget.height ?? 50,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? radius(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.style == GlassButtonStyle.glassy ? 15 : 5,
                  sigmaY: widget.style == GlassButtonStyle.glassy ? 15 : 5,
                ),
                child: Container(
                  padding:
                      widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: _getButtonDecoration(context, buttonColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: _getTextColor(buttonColor),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: _getTextColor(buttonColor),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getButtonDecoration(BuildContext context, Color buttonColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.style) {
      case GlassButtonStyle.solid:
        // BOLD & STRONG - Best for primary actions
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              buttonColor.withOpacity(0.9),
              buttonColor.withOpacity(0.75),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          borderRadius: widget.borderRadius ?? radius(12),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case GlassButtonStyle.glassy:
        // GLASSY - More transparent with blur
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              buttonColor.withOpacity(0.35),
              buttonColor.withOpacity(0.25),
            ],
          ),
          border: Border.all(
            color: buttonColor.withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: widget.borderRadius ?? radius(12),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );

      case GlassButtonStyle.outlined:
        // OUTLINED - Transparent with colored border
        return BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          border: Border.all(
            color: buttonColor.withOpacity(0.6),
            width: 2,
          ),
          borderRadius: widget.borderRadius ?? radius(12),
        );
    }
  }

  Color _getTextColor(Color buttonColor) {
    // For solid style, always use white for maximum contrast
    if (widget.style == GlassButtonStyle.solid) {
      return Colors.white;
    }

    // For glassy/outlined, use the button color
    return widget.style == GlassButtonStyle.outlined ? buttonColor : Colors.white;
  }
}

/// 📝 GLASS LIST TILE
/// Glassmorphic list item
class GlassListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  const GlassListTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            12.width,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  4.height,
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            8.width,
            trailing!,
          ] else if (onTap != null)
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
        ],
      ),
    );
  }
}

/// 🎭 GLASS MODAL BOTTOM SHEET
/// Shows a glassmorphic bottom sheet
Future<T?> showGlassModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (context) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: boxDecorationGlass(
            context,
            intensity: GlassIntensity.strong,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: builder(context),
        ),
      ),
    ),
  );
}
