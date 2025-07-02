import 'package:flutter/material.dart';

class AppAnimations {
  // Enhanced page route with fade and slide
  static PageRoute slideAndFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }

  // Create route for navigation helpers
  static Route<T> createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }

  // Slide transition from bottom
  static Widget slideFromBottom(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<Offset>(
      duration: duration ?? const Duration(milliseconds: 600),
      tween: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
      curve: Curves.easeOutCubic,
      builder: (context, offset, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(offset),
          child: child!,
        );
      },
      child: child,
    );
  }

  // Fade in animation
  static Widget fadeIn(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child!);
      },
      child: child,
    );
  }

  // Scale animation
  static Widget scaleIn(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.8, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child!);
      },
      child: child,
    );
  }

  // Staggered animation for lists
  static Widget staggeredListItem(Widget child, int index, {Duration? delay}) {
    final itemDelay = delay ?? Duration(milliseconds: 100 * index);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(opacity: animation, child: child!),
        );
      },
      child: AnimatedContainer(duration: itemDelay, child: child),
    );
  }

  // Bounce animation for buttons
  static Widget bounceOnTap(Widget child, {VoidCallback? onTap}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      tween: Tween<double>(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return GestureDetector(
          onTapDown: (_) => {},
          onTapUp: (_) => onTap?.call(),
          onTapCancel: () => {},
          child: Transform.scale(scale: scale, child: child!),
        );
      },
      child: child,
    );
  }

  // Shimmer loading effect
  static Widget shimmer(Widget child) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween<double>(begin: -1.0, end: 1.0),
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.transparent,
              ],
              stops: [value - 0.3, value, value + 0.3],
            ).createShader(bounds);
          },
          child: child!,
        );
      },
      child: child,
    );
  }

  // Ripple effect for tap feedback
  static Widget rippleTap(Widget child, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withAlpha(51), // 0.2 * 255 = 51
        highlightColor: Colors.white.withAlpha(25), // 0.1 * 255 = 25
        child: child,
      ),
    );
  }

  // Text animation with typewriter effect
  static Widget typewriterText(
    String text, {
    TextStyle? style,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<int>(
      duration: duration ?? Duration(milliseconds: text.length * 50),
      tween: IntTween(begin: 0, end: text.length),
      builder: (context, value, child) {
        return Text(text.substring(0, value), style: style);
      },
    );
  }

  // Icon animation with rotation and scale
  static Widget animatedIcon(
    IconData icon, {
    Color? color,
    double? size,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Transform.rotate(
            angle: animation * 0.5,
            child: Icon(icon, color: color, size: size),
          ),
        );
      },
    );
  }

  // Card slide in animation
  static Widget slideInCard(Widget child, {Duration? delay}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - animation), 0),
          child: Opacity(opacity: animation, child: child!),
        );
      },
      child: child,
    );
  }
}
