import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../utils/animations.dart';
import '../auth/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check authentication status and navigate accordingly
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for auth initialization to complete
    while (authProvider.status == AuthStatus.initial) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    // Check if it's first launch
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(AppConstants.firstLaunchKey) ?? true;

    if (!mounted) return;

    if (isFirstLaunch) {
      // Mark as not first launch
      await prefs.setBool(AppConstants.firstLaunchKey, false);
      // Navigate to onboarding with smooth transition
      if (mounted) {
        Navigator.of(context).pushReplacement(
          AppAnimations.slideAndFadeRoute(const OnboardingScreen()),
        );
      }
    } else if (authProvider.isAuthenticated) {
      // Navigate to dashboard with smooth transition
      if (mounted) {
        Navigator.of(context).pushReplacement(
          AppAnimations.slideAndFadeRoute(const DashboardScreen()),
        );
      }
    } else {
      // Navigate to login with smooth transition
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(AppAnimations.slideAndFadeRoute(const LoginScreen()));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
              : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/image 1 (1).png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // App Name
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                      ),

                      const SizedBox(height: 10),

                      // App Tagline
                      Text(
                        AppConstants.appTagline,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Loading Indicator
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Loading...',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Designed and Developed by',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.white70,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              AppConstants.companyName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // 5techG Logo
            Image.asset(
              'assets/Group 1.png',
              width: 60,
              height: 30,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              'Version ${AppConstants.appVersion}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
