class AppConstants {
  // App Info
  static const String appName = 'Jivhala Motors';
  static const String appVersion = '1.0.0';
  static const String companyName = '5techG';
  static const String appTagline = 'Your Trusted Vehicle Partner';

  // API Configuration - Using production backend
  static const String _productionBaseUrl =
      'https://backend-0v1f.onrender.com/api'; // Production

  // Base URL for API calls
  static String get baseUrl {
    return _productionBaseUrl;
  }

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  static const String themeKey = 'theme_mode';
  static const String firstLaunchKey = 'first_launch';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String profileEndpoint = '/auth/profile';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String verifyTokenEndpoint = '/auth/verify';

  static const String vehiclesEndpoint = '/vehicles';
  static const String vehicleInEndpoint = '/vehicles/in';
  static const String vehicleOutEndpoint = '/vehicles';
  static const String vehicleStatsEndpoint = '/vehicles/stats/dashboard';

  static const String exportPdfEndpoint = '/export/vehicles/pdf';
  static const String exportCsvEndpoint = '/export/vehicles/csv';

  // Image Configuration
  static const int maxImageCount = 6;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // Vehicle Configuration
  static const List<String> ownerTypes = ['1st', '2nd', '3rd'];
  static const List<String> idProofTypes = ['Aadhaar', 'PAN', 'DL'];
  static const List<String> vehicleStatuses = ['in', 'out'];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 100;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Contact Information
  static const String contactPhone = '+91-XXXXXXXXXX';
  static const String contactEmail = 'info@jivhalamotors.com';
  static const String websiteUrl = 'https://jivhalamotors.com';

  // Privacy & Terms
  static const String privacyPolicyUrl = 'https://jivhalamotors.com/privacy';
  static const String termsConditionsUrl = 'https://jivhalamotors.com/terms';

  // Date Formats
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String timeoutErrorMessage =
      'Request timeout. Please try again.';
  static const String unknownErrorMessage =
      'An unknown error occurred. Please try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String logoutSuccessMessage = 'Logged out successfully!';
  static const String vehicleAddedMessage = 'Vehicle added successfully!';
  static const String vehicleUpdatedMessage = 'Vehicle updated successfully!';
  static const String vehicleDeletedMessage = 'Vehicle deleted successfully!';
  static const String vehicleOutMessage = 'Vehicle marked as out successfully!';

  // Loading Messages
  static const String loadingMessage = 'Loading...';
  static const String savingMessage = 'Saving...';
  static const String uploadingMessage = 'Uploading...';
  static const String deletingMessage = 'Deleting...';
}
