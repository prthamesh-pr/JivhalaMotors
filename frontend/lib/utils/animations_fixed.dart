import 'package:flutter/material.dart';

class AppAnimations {
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

  // Stagger animation for list items
  static Widget staggeredListAnimation(
    Widget child,
    int index, {
    Duration? delay,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      duration:
          (duration ?? const Duration(milliseconds: 600)) +
          Duration(milliseconds: (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child!,
          ),
        );
      },
      child: child,
    );
  }

  // Smooth page transition
  static PageRouteBuilder<T> createRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // Enhanced slide up transition
  static Widget slideUp(Widget child, {Duration? duration, double? offset}) {
    return TweenAnimationBuilder<Offset>(
      duration: duration ?? const Duration(milliseconds: 700),
      tween: Tween<Offset>(begin: Offset(0, offset ?? 0.3), end: Offset.zero),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(value),
          child: child!,
        );
      },
      child: child,
    );
  }

  // Smooth appear animation
  static Widget smoothAppear(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child!,
            ),
          ),
        );
      },
      child: child,
    );
  }

  // Card flip animation
  static Widget flipCard(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value * 0.1),
          child: child!,
        );
      },
      child: child,
    );
  }

  // Hero animation wrapper
  static Widget hero(String tag, Widget child) {
    return Hero(tag: tag, child: child);
  }

  // Slide and fade page transition
  static Route<T> slideAndFadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }
}

// Custom fade page route
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({required this.child, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}
