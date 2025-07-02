import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorHandler {
  // Generic error types
  static const String networkError = 'NETWORK_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String authenticationError = 'AUTHENTICATION_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';

  // Log error for debugging
  static void logError(String error, {String? stackTrace, String? context}) {
    if (kDebugMode) {
      print('🔴 ERROR: $error');
      if (context != null) print('📍 CONTEXT: $context');
      if (stackTrace != null) print('📊 STACK TRACE: $stackTrace');
    }
  }

  // Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred';

    String errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network connection failed. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Access denied. You don\'t have permission for this action.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Requested resource not found.';
    }

    if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return 'Please check your input and try again.';
    }

    if (errorString.contains('email') && errorString.contains('exists')) {
      return 'An account with this email already exists.';
    }

    if (errorString.contains('username') && errorString.contains('exists')) {
      return 'This username is already taken.';
    }

    // Return original error message if no specific case matches
    return error.toString();
  }

  // Get error type for handling
  static String getErrorType(dynamic error) {
    if (error == null) return unknownError;

    String errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return networkError;
    }

    if (errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden')) {
      return authenticationError;
    }

    if (errorString.contains('400') ||
        errorString.contains('validation') ||
        errorString.contains('invalid')) {
      return validationError;
    }

    if (errorString.contains('500') || errorString.contains('server error')) {
      return serverError;
    }

    return unknownError;
  }

  // Show error dialog
  static void showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title ?? 'Error',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          getErrorMessage(error),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                getErrorMessage(error),
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Handle API errors specifically
  static String handleApiError(int? statusCode, String? message) {
    switch (statusCode) {
      case 400:
        return message ?? 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'Requested resource not found.';
      case 409:
        return message ?? 'Conflict error. Data already exists.';
      case 422:
        return message ?? 'Invalid data provided.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable.';
      case 503:
        return 'Service temporarily unavailable.';
      default:
        return message ?? 'An unexpected error occurred.';
    }
  }

  // Check if error requires logout
  static bool shouldLogout(dynamic error) {
    String errorString = error.toString().toLowerCase();
    return errorString.contains('401') ||
        errorString.contains('unauthorized') ||
        errorString.contains('token') && errorString.contains('invalid');
  }

  // Handle platform-specific errors
  static String handlePlatformError(dynamic error) {
    if (Platform.isAndroid) {
      if (error.toString().contains('Permission denied')) {
        return 'Permission denied. Please grant required permissions in settings.';
      }
    }

    if (Platform.isIOS) {
      if (error.toString().contains('User denied')) {
        return 'Permission denied. Please allow access in Settings > Privacy.';
      }
    }

    return getErrorMessage(error);
  }
}
