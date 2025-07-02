import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/vehicle/vehicle_in_screen.dart';
import 'screens/vehicle/vehicle_out_screen.dart';
import 'screens/vehicle/vehicle_details_screen.dart';
import 'screens/vehicle/vehicle_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/common/about_screen.dart';
import 'screens/common/privacy_policy_screen.dart';
import 'screens/common/terms_conditions_screen.dart';
import 'models/vehicle.dart';
import 'utils/animations.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String vehicleList = '/vehicles';
  static const String vehicleIn = '/vehicle-in';
  static const String vehicleOut = '/vehicle-out';
  static const String vehicleDetails = '/vehicle-details';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return AppAnimations.slideAndFadeRoute(const OnboardingScreen());

      case login:
        return AppAnimations.slideAndFadeRoute(const LoginScreen());

      case forgotPassword:
        return AppAnimations.slideAndFadeRoute(const ForgotPasswordScreen());

      case dashboard:
        return AppAnimations.slideAndFadeRoute(const DashboardScreen());

      case vehicleList:
        return AppAnimations.slideAndFadeRoute(const VehicleListScreen());

      case vehicleIn:
        final vehicle = settings.arguments as Vehicle?;
        return AppAnimations.slideAndFadeRoute(
          VehicleInScreen(vehicle: vehicle),
        );

      case vehicleOut:
        final vehicle = settings.arguments as Vehicle?;
        if (vehicle == null) {
          return AppAnimations.slideAndFadeRoute(
            const Scaffold(
              body: Center(
                child: Text(
                  'Vehicle data is required for this screen',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }
        return AppAnimations.slideAndFadeRoute(
          VehicleOutScreen(vehicle: vehicle),
        );

      case vehicleDetails:
        final vehicle = settings.arguments as Vehicle?;
        if (vehicle == null) {
          return AppAnimations.slideAndFadeRoute(
            const Scaffold(
              body: Center(
                child: Text(
                  'Vehicle data is required for this screen',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }
        return AppAnimations.slideAndFadeRoute(
          VehicleDetailsScreen(vehicle: vehicle),
        );

      case profile:
        return AppAnimations.slideAndFadeRoute(const ProfileScreen());

      case editProfile:
        return AppAnimations.slideAndFadeRoute(const EditProfileScreen());

      case changePassword:
        return AppAnimations.slideAndFadeRoute(const ChangePasswordScreen());

      case about:
        return AppAnimations.slideAndFadeRoute(const AboutScreen());

      case privacyPolicy:
        return AppAnimations.slideAndFadeRoute(const PrivacyPolicyScreen());

      case termsConditions:
        return AppAnimations.slideAndFadeRoute(const TermsConditionsScreen());

      default:
        return AppAnimations.slideAndFadeRoute(
          const Scaffold(
            body: Center(
              child: Text('Page not found', style: TextStyle(fontSize: 18)),
            ),
          ),
        );
    }
  }

  // Navigation helpers
  static void pushReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void push(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void pushAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  // Enhanced navigation with animations
  static Future<T?> pushWithAnimation<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(
      context,
    ).push(AppAnimations.createRoute(_getScreenForRoute(routeName, arguments)));
  }

  static Future<T?> pushReplacementWithAnimation<
    T extends Object?,
    TO extends Object?
  >(BuildContext context, String routeName, {Object? arguments, TO? result}) {
    return Navigator.of(context).pushReplacement(
      AppAnimations.createRoute(_getScreenForRoute(routeName, arguments)),
      result: result,
    );
  }

  static Widget _getScreenForRoute(String routeName, Object? arguments) {
    switch (routeName) {
      case onboarding:
        return const OnboardingScreen();
      case login:
        return const LoginScreen();
      case forgotPassword:
        return const ForgotPasswordScreen();
      case dashboard:
        return const DashboardScreen();
      case vehicleList:
        return const VehicleListScreen();
      case vehicleIn:
        return const VehicleInScreen();
      case vehicleOut:
        return VehicleOutScreen(vehicle: arguments as Vehicle);
      case vehicleDetails:
        return VehicleDetailsScreen(vehicle: arguments as Vehicle);
      case profile:
        return const ProfileScreen();
      case editProfile:
        return const EditProfileScreen();
      case changePassword:
        return const ChangePasswordScreen();
      case about:
        return const AboutScreen();
      case privacyPolicy:
        return const PrivacyPolicyScreen();
      case termsConditions:
        return const TermsConditionsScreen();
      default:
        return const Scaffold(body: Center(child: Text('Route not found')));
    }
  }
}

// Custom page route for slide transitions
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlidePageRoute({required this.child, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var slideAnimation =
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return SlideTransition(position: slideAnimation, child: child);
        },
      );
}
