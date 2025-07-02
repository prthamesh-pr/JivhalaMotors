import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  // Initialize the API service
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add request interceptor for error handling and retry logic
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          // Log the error for debugging
          debugPrint('API Error: ${e.message}');

          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            debugPrint('Timeout error - check your connection');
          } else if (e.type == DioExceptionType.connectionError) {
            debugPrint('Connection error - server may be unavailable');
          }

          // Continue with the error
          return handler.next(e);
        },
      ),
    );

    // Add request interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            await _clearAuthData();
          }
          handler.next(error);
        },
      ),
    );

    // Load saved token
    _loadToken();
  }

  // Load token from storage
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  // Save token to storage
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Request failed with status: ${response.statusCode}',
      );
    }
  }

  // Auth APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint(
        'Attempting login with URL: ${AppConstants.baseUrl}${AppConstants.loginEndpoint}',
      );
      debugPrint('Login credentials - Username: $email');

      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {'username': email.trim(), 'password': password},
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response data: ${response.data}');

      final responseData = _handleResponse(response);

      if (responseData['token'] != null) {
        await _saveToken(responseData['token']);

        // Save user data to SharedPreferences
        if (responseData['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            AppConstants.userKey,
            jsonEncode(responseData['user']),
          );
        }
      }

      return responseData;
    } catch (e) {
      debugPrint('Login error: $e');
      if (e is DioException) {
        debugPrint('DioException details: ${e.response?.data}');
        debugPrint('DioException status: ${e.response?.statusCode}');
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: userData,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        AppConstants.forgotPasswordEndpoint,
        data: {'email': email},
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.resetPasswordEndpoint,
        data: {'token': token, 'password': newPassword},
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await _dio.get(AppConstants.verifyTokenEndpoint);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get(AppConstants.profileEndpoint);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(AppConstants.profileEndpoint, data: data);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.changePasswordEndpoint,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Vehicle APIs
  Future<Map<String, dynamic>> getVehicles({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _dio.get(
        AppConstants.vehiclesEndpoint,
        queryParameters: queryParams,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getVehicle(String id) async {
    try {
      final response = await _dio.get('${AppConstants.vehiclesEndpoint}/$id');
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> vehicleIn({
    required Map<String, dynamic> vehicleData,
    List<XFile>? photos,
  }) async {
    try {
      FormData formData = FormData();

      // Add vehicle data with proper conversion
      vehicleData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add photos
      if (photos != null && photos.isNotEmpty) {
        for (int i = 0; i < photos.length && i < 6; i++) {
          XFile photo = photos[i];
          if (kIsWeb) {
            // For web, read bytes and create MultipartFile from bytes
            final bytes = await photo.readAsBytes();
            formData.files.add(
              MapEntry(
                'photos',
                MultipartFile.fromBytes(
                  bytes,
                  filename: photo.name,
                  contentType: MediaType('image', 'jpeg'),
                ),
              ),
            );
          } else {
            // For mobile, use fromFile
            formData.files.add(
              MapEntry(
                'photos',
                await MultipartFile.fromFile(
                  photo.path,
                  filename: photo.path.split('/').last,
                  contentType: MediaType('image', 'jpeg'),
                ),
              ),
            );
          }
        }
      }

      final response = await _dio.post(
        AppConstants.vehicleInEndpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Vehicle In API Error: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> vehicleOut(
    String id,
    Map<String, dynamic> outData, {
    XFile? buyerPhoto,
  }) async {
    try {
      debugPrint('Vehicle Out API - Vehicle ID: $id');
      debugPrint('Vehicle Out API - Data: $outData');

      FormData formData = FormData();

      // Add buyer data
      outData.forEach((key, value) {
        if (value != null) {
          debugPrint('Adding field: $key = $value (${value.runtimeType})');
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add buyer photo if provided
      if (buyerPhoto != null) {
        debugPrint('Adding buyer photo: ${buyerPhoto.name}');
        if (kIsWeb) {
          // For web, read bytes and create MultipartFile from bytes
          final bytes = await buyerPhoto.readAsBytes();
          formData.files.add(
            MapEntry(
              'buyerPhoto',
              MultipartFile.fromBytes(bytes, filename: buyerPhoto.name),
            ),
          );
        } else {
          // For mobile, use fromFile
          formData.files.add(
            MapEntry(
              'buyerPhoto',
              await MultipartFile.fromFile(
                buyerPhoto.path,
                filename: buyerPhoto.path.split('/').last,
              ),
            ),
          );
        }
      }

      debugPrint(
        'Making API call to: ${AppConstants.vehicleOutEndpoint}/$id/out',
      );
      final response = await _dio.post(
        '${AppConstants.vehicleOutEndpoint}/$id/out',
        data: formData,
      );

      debugPrint('Vehicle Out API Response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Vehicle Out API Error: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateVehicle(
    String id,
    Map<String, dynamic> data, {
    List<XFile>? newPhotos,
  }) async {
    try {
      FormData formData = FormData.fromMap(data);

      // Add new photos if provided
      if (newPhotos != null && newPhotos.isNotEmpty) {
        for (var photo in newPhotos) {
          if (kIsWeb) {
            // For web, read as bytes
            final bytes = await photo.readAsBytes();
            formData.files.add(
              MapEntry(
                'newPhotos',
                MultipartFile.fromBytes(bytes, filename: photo.name),
              ),
            );
          } else {
            // For mobile, use fromFile
            formData.files.add(
              MapEntry(
                'newPhotos',
                await MultipartFile.fromFile(
                  photo.path,
                  filename: photo.path.split('/').last,
                ),
              ),
            );
          }
        }
      }

      final response = await _dio.put(
        '${AppConstants.vehiclesEndpoint}/$id',
        data: formData,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteVehicle(String id) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.vehiclesEndpoint}/$id',
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get(AppConstants.vehicleStatsEndpoint);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Export APIs
  Future<String> exportToPdf({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;

      final response = await _dio.get(
        AppConstants.exportPdfEndpoint,
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return base64Encode(response.data);
      } else {
        throw Exception('Failed to export PDF');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> exportToCsv({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;

      final response = await _dio.get(
        AppConstants.exportCsvEndpoint,
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.plain),
      );

      return _handleResponse(response)['data'] ?? response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _clearAuthData();
  }

  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      debugPrint('DioException type: ${error.type}');
      debugPrint('DioException message: ${error.message}');
      debugPrint('DioException response: ${error.response?.data}');

      if (error.response?.data != null) {
        final errorData = error.response!.data;
        if (errorData is Map<String, dynamic>) {
          return Exception(
            errorData['message'] ?? errorData['error'] ?? 'An error occurred',
          );
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
            'Connection timeout. Please check your internet connection.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return Exception('Invalid username or password');
          } else if (statusCode == 404) {
            return Exception('Service not found. Please contact support.');
          } else if (statusCode == 500) {
            return Exception('Server error. Please try again later.');
          }
          return Exception(
            'Server error ($statusCode). Please try again later.',
          );
        case DioExceptionType.connectionError:
          if (error.message?.contains('backend-0v1f.onrender.com') == true) {
            return Exception(
              'Cannot connect to backend server. Please check your internet connection or try again later.',
            );
          }
          return Exception(
            'No internet connection. Please check your network.',
          );
        default:
          return Exception('An unexpected error occurred. Please try again.');
      }
    }

    return Exception(error.toString());
  }

  // Check if user is authenticated
  bool get isAuthenticated => _token != null;

  // Get current token
  String? get token => _token;
}
