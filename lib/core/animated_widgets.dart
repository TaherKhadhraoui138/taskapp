import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Staggered animation for list items
class StaggeredListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final Duration delayPerItem;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delayPerItem = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Animated scale on tap widget
class AnimatedScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleValue;
  final Duration duration;

  const AnimatedScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleValue = 0.95,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedScaleTap> createState() => _AnimatedScaleTapState();
}

class _AnimatedScaleTapState extends State<AnimatedScaleTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleValue).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// Floating animation widget
class FloatingAnimation extends StatefulWidget {
  final Widget child;
  final double distance;
  final Duration duration;

  const FloatingAnimation({
    super.key,
    required this.child,
    this.distance = 10,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: widget.distance).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Pulse animation widget
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? AppBorders.medium,
            gradient: LinearGradient(
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(_controller.value * 2, 0),
            ),
          ),
        );
      },
    );
  }
}

/// Gradient border container
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Color? backgroundColor;

  const GradientBorderContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.borderWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(
            borderRadius.topLeft.x - borderWidth,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Glass morphism container
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.glassDark : AppColors.glassLight),
        borderRadius: borderRadius ?? AppBorders.medium,
        border: border ?? Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// Gradient icon
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}

/// Gradient text
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    required this.gradient,
  this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

/// Animated gradient button
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double height;
  final double? width;
  final bool isLoading;
  final IconData? icon;
  final BorderRadius? borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient = AppGradients.primary,
    this.height = 56,
    this.width,
    this.isLoading = false,
    this.icon,
    this.borderRadius,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (!widget.isLoading) widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: widget.borderRadius ?? AppBorders.medium,
            boxShadow: AppShadows.glow(
              (widget.gradient as LinearGradient).colors.first,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Animated check mark
class AnimatedCheckMark extends StatefulWidget {
  final bool isChecked;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const AnimatedCheckMark({
    super.key,
    required this.isChecked,
    required this.color,
    this.size = 28,
    this.onTap,
  });

  @override
  State<AnimatedCheckMark> createState() => _AnimatedCheckMarkState();
}

class _AnimatedCheckMarkState extends State<AnimatedCheckMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    if (widget.isChecked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value > 1.0 ? 2.2 - _scale.value : _scale.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isChecked
                    ? LinearGradient(
                        colors: [widget.color, widget.color.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: !widget.isChecked
                    ? Border.all(color: widget.color, width: 2)
                    : null,
                boxShadow: widget.isChecked
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: widget.isChecked
                  ? Transform.scale(
                      scale: _checkScale.value,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// Rotating gradient border
class RotatingGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Duration duration;

  const RotatingGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<RotatingGradientBorder> createState() => _RotatingGradientBorderState();
}

class _RotatingGradientBorderState extends State<RotatingGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: const [
                AppColors.primaryStart,
                AppColors.accentStart,
                AppColors.secondaryStart,
                AppColors.primaryStart,
              ],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          padding: EdgeInsets.all(widget.borderWidth),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                widget.borderRadius.topLeft.x - widget.borderWidth,
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Page transition animations
class PageTransitions {
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static Route<T> fadeScale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<T> slideRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

/// Confetti animation for task completion
class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;
  final double progress;

  ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var c in confetti) {
      final paint = Paint()..color = c.color.withOpacity(1 - progress);
      final x = c.x + (c.velocityX * progress * 100);
      final y = c.y + (c.velocityY * progress * 100) + (progress * progress * 200);
      canvas.drawCircle(
        Offset(x, y),
        c.size * (1 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

class Confetti {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double velocityX;
  final double velocityY;

  Confetti({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocityX,
    required this.velocityY,
  });
}

/// Parallax scroll effect
class ParallaxScrollView extends StatelessWidget {
  final Widget background;
  final Widget foreground;
  final double parallaxFactor;

  const ParallaxScrollView({
    super.key,
    required this.background,
    required this.foreground,
    this.parallaxFactor = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => false,
      child: Stack(
        children: [
          background,
          foreground,
        ],
      ),
    );
  }
}

/// Slide animation with delay for staggered entrance animations
class SlideAnimation extends StatefulWidget {
  final dynamic delay; // Can be int (milliseconds) or Duration
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final Curve curve;

  const SlideAnimation({
    super.key,
    this.delay = 0,
    required this.child,
    this.beginOffset = const Offset(0, 50),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int get _delayMs {
    if (widget.delay is Duration) {
      return (widget.delay as Duration).inMilliseconds;
    }
    return widget.delay as int;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(Duration(milliseconds: _delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
