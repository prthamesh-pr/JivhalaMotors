import '../config/constants.dart';

class ImageUtils {
  /// Constructs a proper image URL from the vehicle photo data
  static String getImageUrl(String? photoPath, {String? photoUrl}) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // If the backend provided a URL field, use it
      return '${AppConstants.baseUrl.replaceAll('/api', '')}$photoUrl';
    }

    if (photoPath != null && photoPath.isNotEmpty) {
      // Clean up the path and construct URL
      String cleanPath = photoPath;

      // Remove Windows-style backslashes and replace with forward slashes
      cleanPath = cleanPath.replaceAll('\\', '/');

      // Extract just the uploads part if it's a full path
      if (cleanPath.contains('uploads/')) {
        final index = cleanPath.indexOf('uploads/');
        cleanPath = '/${cleanPath.substring(index)}';
      } else if (!cleanPath.startsWith('/')) {
        cleanPath = '/$cleanPath';
      }

      return '${AppConstants.baseUrl.replaceAll('/api', '')}$cleanPath';
    }

    // Return empty string if no valid path
    return '';
  }

  /// Check if an image URL is valid
  static bool isValidImageUrl(String url) {
    return url.isNotEmpty && (url.startsWith('http') || url.startsWith('/'));
  }
}
